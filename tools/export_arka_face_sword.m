// Apply targeted generated face and weapon detail without changing source alpha or poses.
// clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_face_sword.m -o /tmp/export-arka-face-sword
// /tmp/export-arka-face-sword [output-root]
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>
static CGContextRef canvas(int w,int h){CGColorSpaceRef s=CGColorSpaceCreateDeviceRGB();CGContextRef c=CGBitmapContextCreate(NULL,w,h,8,w*4,s,kCGImageAlphaPremultipliedLast);CGColorSpaceRelease(s);return c;}
static CGImageRef load(NSString*p){CGImageSourceRef s=CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],NULL);NSCAssert(s,@"Missing %@",p);CGImageRef i=CGImageSourceCreateImageAtIndex(s,0,NULL);CFRelease(s);return i;}
static void save(CGImageRef i,NSString*p){CGImageDestinationRef d=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],CFSTR("public.png"),1,NULL);CGImageDestinationAddImage(d,i,NULL);NSCAssert(CGImageDestinationFinalize(d),@"Export failed");CFRelease(d);}
static double light(const unsigned char*p){return (.2126*p[0]+.7152*p[1]+.0722*p[2])/255.;}
int main(int argc,char**argv){@autoreleasepool{
NSString*root=argc>1?[NSString stringWithUTF8String:argv[1]]:@"assets/images/player/arka";
NSMutableArray*runs=[NSMutableArray array];
for(NSString*action in @[@"idle",@"run",@"attack_1",@"attack_2"]){
 CGImageRef generated=load([NSString stringWithFormat:@"docs/art/arka-face-sword/%@-detail.png",action]);
 CGContextRef texture=canvas(1536,768);CGContextSetInterpolationQuality(texture,kCGInterpolationHigh);CGContextDrawImage(texture,CGRectMake(0,0,1536,768),generated);
 unsigned char*detail=CGBitmapContextGetData(texture);int row=0;
 for(NSString*direction in @[@"right",@"left",@"up",@"down"]){
  NSString*name=[action stringByReplacingOccurrencesOfString:@"_" withString:@""];
  NSString*relative=[NSString stringWithFormat:@"%@/%@_%@.png",action,name,direction];
  CGImageRef base=load([@"docs/art/arka-face-sword/base" stringByAppendingPathComponent:relative]);
  NSCAssert(CGImageGetWidth(base)==3072&&CGImageGetHeight(base)==320,@"Unexpected layout");
  CGContextRef out=canvas(3072,320);CGContextDrawImage(out,CGRectMake(0,0,3072,320),base);
  unsigned char*p=CGBitmapContextGetData(out);unsigned char*before=malloc(3072*320*4);memcpy(before,p,3072*320*4);int count=0;
  int faceCount=0, swordCount=0;
  for(int f=0;f<8;f++) {
   BOOL metal[192*192]={0},sword[192*192]={0},visited[192*192]={0};
   int eyeX0=192,eyeY0=192,eyeX1=0,eyeY1=0;
   for(int y=0;y<120;y++)for(int x=0;x<192;x++) {
    unsigned char*b=before+((y+64)*3072+f*384+x+96)*4;
    if(row!=2&&b[3]>240&&b[2]>80&&b[2]>b[0]*1.3&&b[2]>b[1]*1.1) {
     eyeX0=MIN(eyeX0,x);eyeX1=MAX(eyeX1,x);eyeY0=MIN(eyeY0,y);eyeY1=MAX(eyeY1,y);
    }
   }
   BOOL hasFace=eyeX1>=eyeX0;
   CGRect face=hasFace?CGRectMake(eyeX0-7,eyeY0-6,eyeX1-eyeX0+15,eyeY1-eyeY0+23):CGRectZero;
   for(int y=0;y<192;y++)for(int x=0;x<192;x++) {
    unsigned char*b=before+((y+64)*3072+f*384+x+96)*4;
    int hi=MAX(b[0],MAX(b[1],b[2])),lo=MIN(b[0],MIN(b[1],b[2]));
    metal[y*192+x]=b[3]>240&&light(b)>.48&&hi-lo<42&&!(hasFace&&CGRectContainsPoint(face,CGPointMake(x,y)));
   }
   // Select elongated silver components; exclude broad attack arcs and small cuffs.
   for(int start=0;start<192*192;start++)if(metal[start]&&!visited[start]) {
    int queue[192*192],head=0,tail=1;queue[0]=start;visited[start]=YES;
    int x0=192,x1=0,y0=192,y1=0;
    while(head<tail) {
     int v=queue[head++],x=v%192,y=v/192;x0=MIN(x0,x);x1=MAX(x1,x);y0=MIN(y0,y);y1=MAX(y1,y);
     int next[4]={x>0?v-1:-1,x<191?v+1:-1,y>0?v-192:-1,y<191?v+192:-1};
     for(int n=0;n<4;n++)if(next[n]>=0&&metal[next[n]]&&!visited[next[n]]){visited[next[n]]=YES;queue[tail++]=next[n];}
    }
    if(tail>=70&&tail<1500&&MAX(x1-x0,y1-y0)>=24)for(int n=0;n<tail;n++)sword[queue[n]]=YES;
   }
   for(int y=2;y<190;y++)for(int x=2;x<190;x++) {
    int i=((y+64)*3072+f*384+x+96)*4;unsigned char*b=before+i;
    if(b[3]<250)continue;
    BOOL blue=b[2]>80&&b[2]>b[0]*1.3&&b[2]>b[1]*1.1;
    BOOL skin=b[0]>130&&b[1]>70&&b[1]>b[0]*.5&&b[2]<b[1]*.85;
    BOOL pale=light(b)>.70;
    BOOL isFace=hasFace&&CGRectContainsPoint(face,CGPointMake(x,y))&&(skin||blue||pale);
    BOOL isSword=sword[y*192+x];
    BOOL hardware=NO;
    if(!isFace&&!isSword&&b[0]>b[1]&&b[1]>b[2]*1.2&&b[0]<200&&b[0]-b[1]<45) {
     for(int dy=-5;dy<=5;dy++)for(int dx=-5;dx<=5;dx++) {
      int nx=x+dx,ny=y+dy;
      if(nx>=0&&nx<192&&ny>=0&&ny<192&&sword[ny*192+nx])hardware=YES;
     }
    }
    if(!isFace&&!isSword&&!hardware)continue;
    // Never alter the smoothed contour or the original alpha mask.
    BOOL interior=YES;for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++)if(before[i+(dy*3072+dx)*4+3]<240)interior=NO;
    if(!interior)continue;
    unsigned char*t=detail+((row*192+y)*1536+f*192+x)*4;
    if(t[3]<250)continue;
    if(isFace) {
     // Bounded RGB transfer can introduce tiny eyes/nose/mouth accents within the old face.
     for(int c=0;c<3;c++)p[i+c]=MIN(b[3],lround(b[c]*.40+t[c]*.60));
     faceCount++;
    } else if(hardware) {
     if(!(t[0]>t[1]&&t[1]>t[2]*1.2))continue;
     for(int c=0;c<3;c++)p[i+c]=MIN(b[3],lround(b[c]*.60+t[c]*.40));
     swordCount++;
    } else {
     // Keep the existing neutral silver hue, adding bevel/shadow contrast only.
     double shade=MAX(-.24,MIN(.12,(light(t)-light(b))*.60));
     for(int c=0;c<3;c++)p[i+c]=MIN(b[3],MAX(0,lround(b[c]+shade*255)));
     swordCount++;
    }
    count++;
   }
  }
  // The entire smoothed outline, all foot positions and effect coverage stay identical.
  for(int i=3;i<3072*320*4;i+=4)NSCAssert(p[i]==before[i],@"Alpha changed");
  CGImageRef result=CGBitmapContextCreateImage(out);
  NSString*target=[root stringByAppendingPathComponent:relative];
  [[NSFileManager defaultManager]createDirectoryAtPath:[target stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
  save(result,target);printf("%s: %d face / %d sword samples; alpha unchanged\n",[relative UTF8String],faceCount,swordCount);
  if([action isEqualToString:@"run"])[runs addObject:(__bridge id)result];
  free(before);CGContextRelease(out);CGImageRelease(base);row++;
 }
 CGContextRelease(texture);CGImageRelease(generated);
}
CGContextRef preview=canvas(768,192);
CGImageDestinationRef gif=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:@"docs/art/arka-hd/run-preview.gif"],CFSTR("com.compuserve.gif"),8,NULL);
CGImageDestinationSetProperties(gif,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFLoopCount:@0}});
for(int f=0;f<8;f++){
 CGContextSetRGBFillColor(preview,.15,.16,.18,1);CGContextFillRect(preview,CGRectMake(0,0,768,192));
 for(int row=0;row<4;row++){CGImageRef crop=CGImageCreateWithImageInRect((__bridge CGImageRef)runs[row],CGRectMake(f*384+96,64,192,192));CGContextDrawImage(preview,CGRectMake(row*192,0,192,192),crop);CGImageRelease(crop);}
 CGImageRef im=CGBitmapContextCreateImage(preview);
 CGImageDestinationAddImage(gif,im,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFDelayTime:@.07}});
 if(f==2)save(im,@"docs/art/arka-face-sword/preview.png");CGImageRelease(im);
}
NSCAssert(CGImageDestinationFinalize(gif),@"GIF export failed");return 0;
}}
