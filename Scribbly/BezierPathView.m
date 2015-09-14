//
//  BezierPathView.m
//  PictureApp
//
//  Created by William Gu on 6/15/15.
//  Copyright (c) 2015 William Gu. All rights reserved.
//

#import "BezierPathView.h"

typedef struct
{
    CGPoint firstPoint;
    CGPoint secondPoint;
} LineSegment; // ................. (1)

#define CAPACITY 100
#define FF .2
#define LOWER 0.01
#define UPPER 1.0

#define SET_FILL_COLOR [[UIColor clearColor] setFill]

@interface BezierPathView()

@property (nonatomic, strong) NSMutableArray *fullPath;
@property (nonatomic, strong) UIColor *pathColor;



@end


@implementation BezierPathView
{
    CGMutablePathRef pathReference;
    UIImageView *incrementalImage;
    
    CGPoint pts[5];
    uint ctr;
    CGPoint pointsBuffer[CAPACITY];
    uint bufIdx;
    dispatch_queue_t drawingQueue;
    BOOL isFirstTouchPoint;
    LineSegment lastSegmentOfPrev;
    
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void)setPathColor:(UIColor *)color
{
    _pathColor = color;
    if ([color isEqual:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]]) {
        self.backgroundColor = [UIColor whiteColor];
    } else  if ([color isEqual:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]]){
        self.backgroundColor = [UIColor blackColor];
    } else {
        //nothing
    }
}

-(NSMutableArray *)getFullPath
{
    return _fullPath;
}
-(UIImage *)getDrawnImage
{
    return incrementalImage.image;
}
-(CGMutablePathRef)getReferencePath
{
    return pathReference;
}

- (id)initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setMultipleTouchEnabled:NO];
        drawingQueue = dispatch_queue_create("drawingQueue", NULL);
        
        self.opaque = NO;
        self.backgroundColor = [UIColor blackColor]; //Change this to change background color
        
        
        incrementalImage = [[UIImageView alloc] initWithFrame:self.bounds];
        incrementalImage.backgroundColor = [UIColor clearColor];
        incrementalImage.opaque = NO;
        [self addSubview:incrementalImage];
        _pathColor = [UIColor whiteColor];
        pathReference = CGPathCreateMutable();
        _fullPath = [[NSMutableArray alloc] init];
        
        [self addGestureRecognizer:[self createLongPressGesture]];
    }
    return self;
}

-(UILongPressGestureRecognizer *)createLongPressGesture
{
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewLongPressed:)];
    longGesture.delegate = self;
    longGesture.minimumPressDuration = 0.25;
    longGesture.allowableMovement = 5;
    return longGesture;
}
-(UITapGestureRecognizer *)createDoubleTapGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDoubleTapped:)];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 2;
    return tapGesture;
}
-(void)viewLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
    }
    else if (recognizer.state == UIGestureRecognizerStateBegan){
        //prevent double dot
        CGPoint touchPoint = [recognizer locationInView:self];
        [self drawCircleAtPoint:touchPoint];
    }
    
}
-(void)viewDoubleTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint touchPoint = [tapRecognizer locationInView:self];
    [self drawCircleAtPoint:touchPoint];
}

- (void)eraseDrawing:(UITapGestureRecognizer *)t
{
    incrementalImage.image = nil;
    pathReference = nil;
    [_fullPath removeAllObjects];
    pathReference = CGPathCreateMutable();
    [self setNeedsDisplay];
}


//Not working, Could redraw entire signature + circle but would erase multi-color functionality in future
-(void)drawCircle:(CGPoint)point
{
   
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:point radius:5 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    [_pathColor setStroke]; //Stroke color
    [_pathColor setFill]; //Stroke fill
    [bezierPath stroke];
    [bezierPath fill];
    
    CGPathAddPath(pathReference, NULL, bezierPath.CGPath);
    
    incrementalImage.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

}

-(void)drawCircleAtPoint:(CGPoint)point
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:point radius:5 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    CGPathAddPath(pathReference, NULL, bezierPath.CGPath);

    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddPath(context, pathReference);
    CGContextSetStrokeColorWithColor(context, _pathColor.CGColor);
    CGContextSetFillColorWithColor(context, _pathColor.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    incrementalImage.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    bufIdx = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
    isFirstTouchPoint = YES;

    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
        
        for ( int i = 0; i < 4; i++)
        {
            pointsBuffer[bufIdx + i] = pts[i];
        }
        
        bufIdx += 4;
        
        CGRect bounds = self.bounds;
        
        dispatch_async(drawingQueue, ^{
            UIBezierPath *offsetPath = [UIBezierPath bezierPath];
            if (bufIdx == 0) return;
            
            LineSegment ls[4];
            for ( int i = 0; i < bufIdx; i += 4)
            {
                if (isFirstTouchPoint)
                {
                    ls[0] = (LineSegment){pointsBuffer[0], pointsBuffer[0]};
                    [offsetPath moveToPoint:ls[0].firstPoint];
                    isFirstTouchPoint = NO;
                }
                
                else
                    ls[0] = lastSegmentOfPrev;
                
                float frac1 = FF/clamp(len_sq(pointsBuffer[i], pointsBuffer[i+1]), LOWER, UPPER);
                float frac2 = FF/clamp(len_sq(pointsBuffer[i+1], pointsBuffer[i+2]), LOWER, UPPER);
                float frac3 = FF/clamp(len_sq(pointsBuffer[i+2], pointsBuffer[i+3]), LOWER, UPPER);
                ls[1] = [self lineSegmentPerpendicularTo:(LineSegment){pointsBuffer[i], pointsBuffer[i+1]} ofRelativeLength:frac1];
                ls[2] = [self lineSegmentPerpendicularTo:(LineSegment){pointsBuffer[i+1], pointsBuffer[i+2]} ofRelativeLength:frac2];
                ls[3] = [self lineSegmentPerpendicularTo:(LineSegment){pointsBuffer[i+2], pointsBuffer[i+3]} ofRelativeLength:frac3];
                
                [offsetPath moveToPoint:ls[0].firstPoint];
                [offsetPath addCurveToPoint:ls[3].firstPoint controlPoint1:ls[1].firstPoint controlPoint2:ls[2].firstPoint];
                [offsetPath addLineToPoint:ls[3].secondPoint];
                [offsetPath addCurveToPoint:ls[0].secondPoint controlPoint1:ls[2].secondPoint controlPoint2:ls[1].secondPoint];
                [offsetPath closePath];
                lastSegmentOfPrev = ls[3];
                
            }
            [_fullPath addObject:offsetPath];
            UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0);
            
            if (!incrementalImage.image)
            {
                UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
                [[UIColor clearColor] setFill];
                [rectpath fill];
                
            }
            [incrementalImage.image drawAtPoint:CGPointZero];
            [_pathColor setStroke]; //Stroke color
            [_pathColor setFill]; //Stroke fill
            [offsetPath stroke];
            [offsetPath fill];
            CGPathAddPath(pathReference, NULL, offsetPath.CGPath);
            incrementalImage.image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            [offsetPath removeAllPoints];
            dispatch_async(dispatch_get_main_queue(), ^{
                bufIdx = 0;
                [self setNeedsDisplay];
            });
        });
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}

- (void)drawRect:(CGRect)rect
{
    [incrementalImage.image drawInRect:rect];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

-(LineSegment) lineSegmentPerpendicularTo: (LineSegment)pp ofRelativeLength:(float)fraction
{
    CGFloat x0 = pp.firstPoint.x, y0 = pp.firstPoint.y, x1 = pp.secondPoint.x, y1 = pp.secondPoint.y;
    
    CGFloat dx, dy;
    dx = x1 - x0;
    dy = y1 - y0;
    
    CGFloat xa, ya, xb, yb;
    xa = x1 + fraction/2 * dy;
    ya = y1 - fraction/2 * dx;
    xb = x1 - fraction/2 * dy;
    yb = y1 + fraction/2 * dx;
    
    return (LineSegment){ (CGPoint){xa, ya}, (CGPoint){xb, yb} };
    
}

float len_sq(CGPoint p1, CGPoint p2)
{
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;
    return dx * dx + dy * dy;
}

float clamp(float value, float lower, float higher)
{
    if (value < lower) return lower;
    if (value > higher) return higher;
    return value;
}

-(void)setupDrawing
{
    //INIT
    [self setMultipleTouchEnabled:NO];
    drawingQueue = dispatch_queue_create("drawingQueue", NULL);
    
    self.opaque = NO;
    self.backgroundColor = [UIColor blackColor]; //Change this to change background color
    
    
    incrementalImage = [[UIImageView alloc] initWithFrame:self.bounds];
    incrementalImage.backgroundColor = [UIColor clearColor];
    incrementalImage.opaque = NO;
    [self addSubview:incrementalImage];
    _pathColor = [UIColor whiteColor];
    pathReference = CGPathCreateMutable();
    _fullPath = [[NSMutableArray alloc] init];
    
    [self addGestureRecognizer:[self createLongPressGesture]];
    ///***
}


@end
