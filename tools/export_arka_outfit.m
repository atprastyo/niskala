// Register generated side-part hair detail and recolor clothing, preserving alpha and all poses.
// clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_outfit.m -o /tmp/export-arka-outfit
// /tmp/export-arka-outfit [output-root]
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <ImageIO/ImageIO.h>
static CGContextRef canvas(int w,int h){CGColorSpaceRef s=CGColorSpaceCreateDeviceRGB();CGContextRef c=CGBitmapContextCreate(NULL,w,h,8,w*4,s,kCGImageAlphaPremultipliedLast);CGColorSpaceRelease(s);return c;}
static CGImageRef load(NSString*p){CGImageSourceRef s=CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],NULL);NSCAssert(s,@"Missing %@",p);CGImageRef i=CGImageSourceCreateImageAtIndex(s,0,NULL);CFRelease(s);return i;}
static void save(CGImageRef i,NSString*p){CGImageDestinationRef d=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:p],CFSTR("public.png"),1,NULL);CGImageDestinationAddImage(d,i,NULL);NSCAssert(CGImageDestinationFinalize(d),@"Export failed");CFRelease(d);}
static double light(const unsigned char*p){return (.2126*p[0]+.7152*p[1]+.0722*p[2])/255.;}
static CGRect hairMask(unsigned char *ref,int f,BOOL *mask) {
 BOOL eligible[96*80]={0};int seed=-1;
 for(int y=16;y<42;y++)for(int x=24;x<72;x++) {
  unsigned char*c=ref+(y*768+f*96+x)*4;unsigned int rgb=(c[0]<<16)|(c[1]<<8)|c[2];
  BOOL brown=c[3]>128&&(rgb==0x391f21||rgb==0x5d2c28||rgb==0x1c121c);eligible[y*96+x]=brown;if(brown&&seed<0)seed=y*96+x;
 }
 NSCAssert(seed>=0,@"Missing hair mask");int q[7680],head=0,tail=1;q[0]=seed;mask[seed]=YES;int limit=seed/96+14,x0=96,x1=0,y0=80,y1=0;
 while(head<tail){int v=q[head++],x=v%96,y=v/96;x0=MIN(x0,x);x1=MAX(x1,x);y0=MIN(y0,y);y1=MAX(y1,y);for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int nx=x+dx,ny=y+dy;if(nx<0||nx>=96||ny<0||ny>=80||ny>limit)continue;int n=ny*96+nx;if(eligible[n]&&!mask[n]){mask[n]=YES;q[tail++]=n;}}}
 return CGRectMake(x0*4,y0*4,(x1-x0+1)*4,(y1-y0+1)*4);
}
static double hairAngle(BOOL *mask) {
 double mx=0,my=0,n=0,xx=0,yy=0,xy=0;for(int y=0;y<80;y++)for(int x=0;x<96;x++)if(mask[y*96+x]){mx+=x;my+=y;n++;}mx/=n;my/=n;
 for(int y=0;y<80;y++)for(int x=0;x<96;x++)if(mask[y*96+x]){xx+=(x-mx)*(x-mx);yy+=(y-my)*(y-my);xy+=(x-mx)*(y-my);}return .5*atan2(2*xy,xx-yy);
}
static BOOL neutral(const unsigned char*c){int hi=MAX(c[0],MAX(c[1],c[2])),lo=MIN(c[0],MIN(c[1],c[2]));return c[3]>220&&lo>115&&hi-lo<48;}
int main(int argc,char**argv){@autoreleasepool{
NSString*root=argc>1?[NSString stringWithUTF8String:argv[1]]:@"assets/images/player/arka";
CGImageRef art=load(@"docs/art/arka-outfit/style-design.png");CGContextRef style=canvas(384,384);CGContextSetInterpolationQuality(style,kCGInterpolationHigh);CGContextDrawImage(style,CGRectMake(0,0,384,384),art);unsigned char*tex=CGBitmapContextGetData(style);
CGRect patches[4]={CGRectMake(64,30,59,46),CGRectMake(63,30,60,46),CGRectMake(70,26,51,47),CGRectMake(63,26,53,47)};
NSMutableArray*runs=[NSMutableArray array];
for(NSString*action in @[@"idle",@"run",@"attack_1",@"attack_2"]){int row=0;
 for(NSString*direction in @[@"right",@"left",@"up",@"down"]){
  NSString*name=[action stringByReplacingOccurrencesOfString:@"_" withString:@""];
  NSString*relative=[NSString stringWithFormat:@"%@/%@_%@.png",action,name,direction];CGImageRef base=load([@"docs/art/arka-outfit/base" stringByAppendingPathComponent:relative]);
  CGImageRef original=load([@"docs/art/arka-originals" stringByAppendingPathComponent:relative]);CGContextRef template=canvas(768,80);CGContextDrawImage(template,CGRectMake(0,0,768,80),original);unsigned char*ref=CGBitmapContextGetData(template);
  CGImageRef idle=load([NSString stringWithFormat:@"docs/art/arka-originals/idle/idle_%@.png",direction]);CGContextRef idleTemplate=canvas(768,80);CGContextDrawImage(idleTemplate,CGRectMake(0,0,768,80),idle);BOOL idleMask[7680]={0};CGRect idleBox=hairMask(CGBitmapContextGetData(idleTemplate),0,idleMask);double idleAngle=hairAngle(idleMask);
  CGContextRef out=canvas(3072,320);CGContextDrawImage(out,CGRectMake(0,0,3072,320),base);unsigned char*p=CGBitmapContextGetData(out),*before=malloc(3072*320*4);memcpy(before,p,3072*320*4);
  int hairCount=0,coatCount=0,innerCount=0,pantsCount=0,rustCount=0;
  for(int f=0;f<8;f++) {
   BOOL hair[7680]={0};CGRect box=hairMask(ref,f,hair);double angle=hairAngle(hair)-idleAngle;while(angle>M_PI_2)angle-=M_PI;while(angle<-M_PI_2)angle+=M_PI;angle=MAX(-.30,MIN(.30,angle));
   int eyeY=0;for(int oy=16;oy<42;oy++)for(int ox=24;ox<72;ox++){unsigned char*c=ref+(oy*768+f*96+ox)*4;if(c[3]>220&&c[0]==0&&c[1]==105&&c[2]==170)eyeY=MAX(eyeY,oy*4+3);}
   BOOL *wrist=calloc(384*320,sizeof(BOOL)),*seen=calloc(384*320,sizeof(BOOL));
   for(int start=0;start<384*320;start++){
    int sx=start%384,sy=start/384;if(seen[start]||!neutral(before+(sy*3072+f*384+sx)*4))continue;
    int *q=malloc(384*320*sizeof(int)),head=0,tail=1;q[0]=start;seen[start]=YES;int x0=384,x1=0,y0=320,y1=0;
    while(head<tail){int v=q[head++],x=v%384,y=v/384;x0=MIN(x0,x);x1=MAX(x1,x);y0=MIN(y0,y);y1=MAX(y1,y);int ns[4]={x>0?v-1:-1,x<383?v+1:-1,y>0?v-384:-1,y<319?v+384:-1};for(int n=0;n<4;n++)if(ns[n]>=0&&!seen[ns[n]]){int nx=ns[n]%384,ny=ns[n]/384;if(neutral(before+(ny*3072+f*384+nx)*4)){seen[ns[n]]=YES;q[tail++]=ns[n];}}}
    if(tail>=8&&tail<350&&x1-x0<=22&&y1-y0<=24&&y0>CGRectGetMaxY(box)-14&&y1<224&&x0>136&&x1<248)for(int n=0;n<tail;n++)wrist[q[n]]=YES;free(q);
   }
   double torsoX=0,torsoN=0;for(int y=156;y<218;y++)for(int x=140;x<244;x++){unsigned char*c=before+(y*3072+f*384+x)*4;if(c[3]>220&&c[0]>65&&c[1]<c[0]*.62&&c[2]<c[0]*.65){torsoX+=x;torsoN++;}}torsoX=torsoN?torsoX/torsoN:192;
   for(int y=64;y<256;y++)for(int x=96;x<288;x++) {
    int i=(y*3072+f*384+x)*4;unsigned char*c=p+i,*b=before+i;if(b[3]<32)continue;double a=b[3]/255.,r=b[0]/a,g=b[1]/a,bl=b[2]/a;BOOL isHair=NO;
    if(y<180&&r>=10&&r<155&&g<100&&r>g*.97&&r>bl*.85)for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int nx=(x+dx)/4,ny=(y+dy)/4;if(nx>=0&&nx<96&&ny>=0&&ny<80&&hair[ny*96+nx])isHair=YES;}
    if(isHair){double u=(x-CGRectGetMidX(box))/box.size.width,v=(y-CGRectGetMidY(box))/box.size.height;double ru=cos(angle)*u+sin(angle)*v,rv=-sin(angle)*u+cos(angle)*v;CGRect patch=patches[row];int tx=MAX(0,MIN(191,lround(patch.origin.x+(ru+.5)*patch.size.width))),ty=MAX(0,MIN(191,lround(patch.origin.y+(rv+.5)*patch.size.height)));unsigned char*t=tex+(((row/2)*192+ty)*384+(row%2)*192+tx)*4;
     if(t[3]>220&&t[0]<155&&t[1]<110&&t[2]<100){for(int k=0;k<3;k++)c[k]=MIN(b[3],lround((t[k]*.88+(b[k]/a)*.12)*a));hairCount++;}continue;}
    BOOL collar=!([action hasPrefix:@"attack"]&&f>=1&&f<=3)&&eyeY>0&&y>=eyeY+1&&y<=eyeY+25&&fabs(x-CGRectGetMidX(box))<25&&neutral(b);
    if(collar){double t=MAX(0,MIN(1,(light(b)/a-.35)/.65));c[0]=lround((87+70*t)*a);c[1]=lround((39+36*t)*a);c[2]=lround((31+30*t)*a);rustCount++;continue;}
    if(wrist[y*384+x]){double t=MAX(0,MIN(1,(light(b)/a-.15)/.85));c[0]=lround((184+61*t)*a);c[1]=lround((189+57*t)*a);c[2]=lround((199+49*t)*a);continue;}
    unsigned char*o=ref+((y/4)*768+f*96+x/4)*4;unsigned int rgb=(o[0]<<16)|(o[1]<<8)|o[2];
    if(y>CGRectGetMaxY(box)+15&&(rgb==0x1b1b1b||rgb==0x272727||rgb==0x3d3d3d)) {double t=MAX(0,MIN(1,light(b)/a/.32));c[0]=lround((12+24*t)*a);c[1]=lround((18+28*t)*a);c[2]=lround((37+45*t)*a);pantsCount++;continue;}
    if(y>CGRectGetMaxY(box)-3&&y<224&&r>65&&g<r*.62&&bl<r*.65){double t=MAX(0,MIN(1,(light(b)/a-.12)/.42));c[0]=lround((25+80*t)*a);c[1]=lround((40+100*t)*a);c[2]=lround((68+112*t)*a);coatCount++;}

   }
   // Pose-specific material repairs: raised side-attack armor and rear idle collar/cuffs.
   BOOL sideAttack=[action hasPrefix:@"attack"]&&row<2;
   BOOL rearIdle=[action isEqualToString:@"idle"]&&row==2;
   for(int y=96;y<224;y++)for(int x=136;x<248;x++) {
    int i=(y*3072+f*384+x)*4;unsigned char*c=p+i,*b=before+i;if(b[3]<100)continue;
    unsigned char*o=ref+((y/4)*768+f*96+x/4)*4;unsigned int rgb=(o[0]<<16)|(o[1]<<8)|o[2];double a=b[3]/255.;
    BOOL missedCoat=sideAttack&&(rgb==0x571c27||rgb==0x891e2b||rgb==0xc42430)&&c[0]>c[1]*1.12&&c[0]>c[2]*1.15;
    BOOL nearHand=NO;
    BOOL faceArea=eyeY>0&&fabs(x-CGRectGetMidX(box))<20&&y<eyeY+20;
    if(sideAttack&&f!=1&&f!=2&&!faceArea&&y>box.origin.y+box.size.height*.65&&(neutral(b)||rgb==0x5d2c28||rgb==0x391f21)) {
     double bodyDistance=hypot(x-torsoX,y-185);
     for(int dy=-7;dy<=7&&!nearHand;dy++)for(int dx=-7;dx<=7;dx++) {
      if(dx*dx+dy*dy>49)continue;int nx=x+dx,ny=y+dy;if(nx<96||nx>=288||ny<96||ny>=224)continue;
      unsigned char*skin=ref+((ny/4)*768+f*96+nx/4)*4;unsigned int sk=(skin[0]<<16)|(skin[1]<<8)|skin[2];
      if((sk==0xe69c69||sk==0xf6ca9f||sk==0xbf6f4a)&&bodyDistance+3<hypot(nx-torsoX,ny-185)){nearHand=YES;break;}
     }
    }
    BOOL guardMaterial=sideAttack&&(wrist[y*384+x]||nearHand);
    if(guardMaterial){double t=MAX(0,MIN(1,(light(b)/a-.15)/.85));c[0]=lround((184+61*t)*a);c[1]=lround((189+57*t)*a);c[2]=lround((199+49*t)*a);continue;}
    if(missedCoat){double t=MAX(0,MIN(1,(light(b)/a-.12)/.42));c[0]=lround((25+80*t)*a);c[1]=lround((40+100*t)*a);c[2]=lround((68+112*t)*a);coatCount++;continue;}
    double localX=x-(box.origin.x-idleBox.origin.x),localY=y-(box.origin.y-idleBox.origin.y);
    BOOL rearRust=rearIdle&&(localX>=171&&localX<200&&localY>=142&&localY<156);
    BOOL rearCuff=rearIdle&&((localX>=151&&localX<173&&localX<183-(localY-164)*.9&&localY>=166&&localY<184)||(localX>=211&&localX<228&&localY>=166&&localY<190));
    if(rearCuff&&neutral(b)){double t=MAX(0,MIN(1,(light(b)/a-.15)/.85));c[0]=lround((184+61*t)*a);c[1]=lround((189+57*t)*a);c[2]=lround((199+49*t)*a);continue;}
    BOOL upAttackScarf=[action hasPrefix:@"attack"]&&row==2&&((f==0&&localX>=171&&localX<200&&localY>=142&&localY<156)||(f>0&&fabs(x-CGRectGetMidX(box))<21&&y>=CGRectGetMaxY(box)-12&&y<CGRectGetMaxY(box)+10));
    if((rearRust||upAttackScarf)&&neutral(b)){double t=MAX(0,MIN(1,(light(b)/a-.35)/.65));c[0]=lround((87+70*t)*a);c[1]=lround((39+36*t)*a);c[2]=lround((31+30*t)*a);rustCount++;}
   }
   free(wrist);free(seen);
  }
  for(int i=3;i<3072*320*4;i+=4)NSCAssert(p[i]==before[i],@"Animation silhouette changed");
  CGImageRef result=CGBitmapContextCreateImage(out);NSString*target=[root stringByAppendingPathComponent:relative];[[NSFileManager defaultManager]createDirectoryAtPath:[target stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];save(result,target);printf("%s: hair%d blue%d white%d navy%d rust%d; alpha unchanged\n",[relative UTF8String],hairCount,coatCount,innerCount,pantsCount,rustCount);
  if([action isEqualToString:@"run"])[runs addObject:(__bridge id)result];free(before);CGContextRelease(out);CGContextRelease(template);CGContextRelease(idleTemplate);CGImageRelease(base);CGImageRelease(original);CGImageRelease(idle);row++;
 }
}
CGContextRef preview=canvas(768,192);
CGImageDestinationRef gif=CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:@"docs/art/arka-hd/run-preview.gif"],CFSTR("com.compuserve.gif"),8,NULL);
CGImageDestinationSetProperties(gif,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFLoopCount:@0}});
for(int f=0;f<8;f++){
 CGContextSetRGBFillColor(preview,.15,.16,.18,1);CGContextFillRect(preview,CGRectMake(0,0,768,192));
 for(int row=0;row<4;row++){CGImageRef crop=CGImageCreateWithImageInRect((__bridge CGImageRef)runs[row],CGRectMake(f*384+96,64,192,192));CGContextDrawImage(preview,CGRectMake(row*192,0,192,192),crop);CGImageRelease(crop);}
 CGImageRef im=CGBitmapContextCreateImage(preview);
 CGImageDestinationAddImage(gif,im,(__bridge CFDictionaryRef)@{(__bridge NSString*)kCGImagePropertyGIFDictionary:@{(__bridge NSString*)kCGImagePropertyGIFDelayTime:@.07}});
 if(f==2)save(im,@"docs/art/arka-outfit/preview.png");CGImageRelease(im);
}
NSCAssert(CGImageDestinationFinalize(gif),@"GIF export failed");return 0;
}}
