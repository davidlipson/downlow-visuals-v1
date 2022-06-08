import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import processing.sound.*;
import java.util.Random;
import blobDetection.*;
import processing.video.*;

int nInputs = 4;
int nVisuals = 8;
int currentVisual = 0;
int bands = 32;
int clock = 0;
PGraphics currentGraphic;
String name = "ADVERSARIAL NETWORKS";

// **** THIS IS THE FIELD
String descriptionText = "THIS PERFORMANCE ....";
// ****

Kinect kin;

// VISUAL PARENT CLASS
public class Visual{
  AudioSource[] sources;
  PGraphics pg;
  PGraphics last;
  
  public Visual(AudioSource[] s){
    sources = s;
  }
  
  public void setLast(PGraphics l){
    last = l;
  }
  
  public void reset(){}
  
  public PGraphics step(){
    this.updateAudio();
    
    pg.beginDraw();
    this.updateGraphic();
    pg.endDraw();
    
    this.updateFields();

    return pg;
  }
  
  public void updateGraphic(){
    pg.background(0);
    pg.circle(width/2, height/2, sources[0].volume*1000);
  }
  
  public void updateFields(){}
  
  public void updateAudio(){
    for (int n = 0; n < nInputs; n++){
      sources[n].update();
    }
  }
}

////////////////////////////
////////////////////////////
///  VISUAL 1: STARFIELD ///
////////////////////////////
////////////////////////////
public class StarField extends Visual {
  
    class Star{
      Random rand = new Random();
      int maxLife = rand.nextInt(800);
      int lifetime = maxLife;
      int x = rand.nextInt(width);
      int y = rand.nextInt(height);
      int z = -clock - rand.nextInt(200);
      int size = rand.nextInt(3);
    }
    
    int nStars = 1500;
    Star[] stars;
    Boolean redraw;
    PGraphics og;
    Boolean startShow;
    
    public StarField(AudioSource[] str, Boolean red){
      super(str);
      stars = new Star[nStars];
      redraw = red;
      pg = createGraphics(width, height, P3D);
      og = createGraphics(width, height, P3D);
      for (int s = 0; s < nStars; s++){
        stars[s] = new Star();
      }
      startShow = true;
    }
    
    public void reset(){
      startShow = false;
    }
    
    public void updateGraphic(){
      og.beginDraw();
      og.translate(0,0,clock);
      if (redraw) pg.background(0);
      og.noFill();
      
      for (int s = 0; s < nStars; s++){
        if(redraw){
          og.stroke(255);
        }
        else{
          og.stroke(sources[0].volume*2550, sources[1].volume*2550, sources[2].volume*2550);
        }
        float sumOfVols = sources[0].volume*5 + sources[1].volume*5 + sources[2].volume*5 + sources[3].volume*5;
        float weight = stars[s].size + (redraw ? sumOfVols : sumOfVols*3);
        if(stars[s].lifetime < 20) weight += cos(PI*(20-stars[s].lifetime)/20)*3;
        og.strokeWeight(weight);
        og.point(stars[s].x + 10*sin(stars[s].x + clock/100.) + sumOfVols*5, stars[s].y + 10*cos(stars[s].x + clock/100.), stars[s].z);

      }
      if (redraw && startShow){
        og.textAlign(CENTER);
        og.fill((clock % 500)*255/500.);
        og.text(name, width/2, height/2, -clock + (clock % 500));
        og.text("THE SHOW IS ABOUT TO BEGIN", width/2, height/2 + 30, -clock + (clock % 500));
        og.text(descriptionText, width/2, height/2 + 60, -clock + (clock % 500));
      }
      og.endDraw();
      pg.loadPixels();
      og.loadPixels();
        if(!redraw){
          if (clock % width < width / 4){
            for(int x = 0; x < width; x++){
              for(int y = 0; y < height; y++){
                int offset = x + y*width;
                int oldset;
                if (y % 5 < 3){
                  oldset = x + max(0, y - (clock % height))*width;
                }
                else{
                  oldset = x + min(height - 1, y + (clock % height))*width;
                }
                pg.pixels[offset] = og.pixels[oldset];
              }
            }
          }
          else{
            for(int y = 0; y < height; y++){
            for(int x = 0; x < width; x++){
              int offset = y + x*height;
              int oldset;
              if (y % 5 < 3){
                oldset = x + max(0, y - (clock % height))*width;
              }
              else{
                oldset = x + min(height - 1, y + (clock % height))*width;
              }
              pg.pixels[offset] = og.pixels[oldset];
            }
          }
          }
          
        }
        else{
          for(int x = 0; x < width; x++){
            for(int y = 0; y < height; y++){
              int offset = x + y*width;
              pg.pixels[offset] = og.pixels[offset];
            }
          }
        }
        pg.updatePixels();
        for(int x = 0; x < width; x++){
            for(int y = 0; y < height; y++){
              int offset = x + y*width;
              og.pixels[offset] = pg.pixels[offset];
            }
          }
       og.updatePixels();

     }  
    
    public void updateFields(){
      for (int s = 0; s < nStars; s++){
        stars[s].lifetime--;
        if(stars[s].lifetime <= 0){
          stars[s] = new Star();
        }
           
      }
    }
}

////////////////////////////
////////////////////////////
///  VISUAL 1: STARFIELD ///
////////////////////////////
////////////////////////////
public class LineGeom extends Visual {
  
    PGraphics orb;
    Random rand = new Random();
    PGraphics og;
    int hour = 0;
    int min = 0;
    int lastMin = 0;

    public LineGeom(AudioSource[] str){
      super(str);
      pg = createGraphics(width, height, P3D);
      orb = createGraphics(width, height, P3D);
      og = createGraphics(width, height, P3D);
    }
    
   
    public void updateGraphic(){
      og.beginDraw();
      orb.beginDraw();
      orb.stroke(255);
      orb.background(0);
      orb.lights();
      orb.ambientLight(10*255*sources[0].volume, 0, 0);
      orb.translate(orb.width/2, orb.height/2);
      orb.rotateY(radians(clock/5));
      orb.sphere(100);
      orb.noFill();
      orb.endDraw();
    
      og.image(orb, 0, 0);
      og.stroke(255);
      og.noFill();
      
    
      
      for(int fs = 0; fs < 5; fs++){
        og.beginShape();
        for(int x = 0; x <= bands/2; x++){
          og.curveVertex(x*(2*width/bands), 4*height/5 + fs*5 + 5*sin(x + clock/10) + 50*sources[0].spectrum[x]);
        }
        og.endShape();
      }
      
      for(int fs = 0; fs < 5; fs++){
        og.beginShape();
        for(int x = 0; x <= bands/2; x++){
          og.curveVertex((bands/2 - x)*(2*width/bands), height/5 - fs*5  + 5*sin(x + clock/10) - 50*sources[0].spectrum[x]);
        }
        og.endShape();
      }
      
        
      og.line(width/4 + 40, height/2, 3*width/4 - 40, height/2);
      og.line(width/4 + 40, height/2 - 10, width/4 + 40, height/2 + 10);
      og.line(3*width/4 - 40, height/2 - 10, 3*width/4 - 40, height/2 + 10);
      
      
      og.fill(255);
      og.noStroke();
      og.arc(width/2, height/2, 100, 100, 0, PI*clock/180 % 2*PI, PIE);
      og.fill(255,0,0);
      og.circle(width/2,height/2,60);
      og.fill(255);

      og.textSize(60);
      og.textAlign(CENTER);
      og.text(PI*clock/180 % 4*PI < 2*PI ? "A" : "N", width/2,height/2+(PI*clock/180 % 4*PI < 2*PI ? 17 : 19));
      
      og.textSize(30);
      lastMin = min;
      min = clock/10 % 60;
      String mn = Integer.toString(min);
      if (min == 0 && min != lastMin){
        hour = (hour + 1) % 12;
      }
      String hr = Integer.toString(hour);
      
      og.text(("00" + hr).substring(hr.length()), width/4 - 40, height/2 + 10);
      og.text(":", width/4 - 20, height/2 + 10);
      og.text(("00" + mn).substring(mn.length()), width/4, height/2 + 10);
      
      og.text(("00" + hr).substring(hr.length()), 3*width/4, height/2 + 10);
      og.text(":", 3*width/4 + 20, height/2 + 10);
      og.text(("00" + mn).substring(mn.length()), 3*width/4 + 40, height/2 + 10);
      
      og.fill(sources[0].volume*2550,0,0);
      og.square((width - 700)/2, height/4, 100);
      og.fill(0,sources[1].volume*2550,0);
      og.square((width - 700)/2 + 100, height/4, 100);
      og.fill(0,0,sources[2].volume*2550);
      og.square((width - 700)/2 + 200, height/4, 100);
      og.fill(0,sources[3].volume*2550,sources[3].volume*2550);
      og.square((width - 700)/2 + 300, height/4, 100);
      og.fill(sources[0].volume*2550,sources[1].volume*2550,sources[2].volume*2550);
      og.square((width - 700)/2 + 400, height/4, 100);
      og.fill(sources[3].volume*2550,sources[2].volume*2550,0);
      og.square((width - 700)/2 + 500, height/4, 100);
      og.fill(255,0,sources[2].volume*2550);
      og.square((width - 700)/2 + 600, height/4, 100);
     
      og.fill(sources[0].volume*2550,0,0);
      og.square((width - 700)/2, 3*height/4 - 115, 100);
      og.fill(0,sources[1].volume*2550,0);
      og.square((width - 700)/2 + 100, 3*height/4 - 115, 100);
      og.fill(0,0,sources[2].volume*2550);
      og.square((width - 700)/2 + 200, 3*height/4 - 115, 100);
      og.fill(0,sources[3].volume*2550,sources[3].volume*2550);
      og.square((width - 700)/2 + 300, 3*height/4 - 115, 100);
      og.fill(sources[0].volume*2550,sources[1].volume*2550,sources[2].volume*2550);
      og.square((width - 700)/2 + 400, 3*height/4 - 115, 100);
      og.fill(sources[3].volume*2550,sources[2].volume*2550,0);
      og.square((width - 700)/2 + 500, 3*height/4 - 115, 100);
      og.fill(255,0,sources[2].volume*2550);
      og.square((width - 700)/2 + 600, 3*height/4 - 115, 100);
      
      og.line(
        (2*width/bands), 4*height/5  + 5*sin(1 + clock/10) + 50*sources[0].spectrum[1], 
        width/2 + 200*cos(-225*PI/180), height/2 + 200*sin(-225*PI/180));
      og.line(
        ((bands/2) - 1)*(2*width/bands), 4*height/5  + 5*sin(((bands/2) - 1) + clock/10) + 50*sources[0].spectrum[(bands/2) - 1], 
         width/2 + 200*cos(-315*PI/180), height/2 + 200*sin(-315*PI/180));
      
      og.line(
        ((bands/2) - 1)*(2*width/bands), height/5  + 5*sin(1 + clock/10) - 50*sources[0].spectrum[1], 
        width/2 + 200*cos(-45*PI/180), height/2 + 200*sin(-45*PI/180));
      og.line(
        2*(width/bands), height/5  + 5*sin(((bands/2) - 1) + clock/10) - 50*sources[0].spectrum[((bands/2) - 1)], 
        width/2 + 200*cos(-135*PI/180), height/2 + 200*sin(-135*PI/180));
        
      og.endDraw();
      og.loadPixels();
      pg.loadPixels();
      
      for(int x = 0; x < width; x++){
        for(int y = 0; y < height; y++){
          int offset = (rand.nextInt(10) < 8 ? rand.nextInt(width): x) + (rand.nextInt(10) < 8 ? rand.nextInt(height)*width : y*width);
          pg.pixels[offset] = og.pixels[offset];
        }
      }
      
      pg.updatePixels();

    }
}

public class Shapes extends Visual {
  
    class Piece{
      int x;
      int y;
      int dirX;
      int dirY;
      
      public Piece(int a, int b, int c, int d){
        x = a;
        y = b;
        dirX = c;
        dirY = d;
      }
    }
    
    Piece[] pieces;
    int nPieces = 10;
    int piecesUsed = 0;
  
    public Shapes(AudioSource[] str){
      super(str);
      pg = createGraphics(width, height);
      pieces = new Piece[10];
      pieces[0] = new Piece(width/2, height/2, 1, 0);
      piecesUsed = 1;
    }
    
   
    public void updateGraphic(){
      pg.stroke(255);
      int p = 0;
      while(pieces[p] != null){
        pg.point(pieces[p].x, pieces[p].y);
        p++;
      }
      
    }
    
    public void updateFields(){
      int p = 0;
      while(pieces[p] != null){
        pieces[p].x = (pieces[p].x + pieces[p].dirX) % width;
        pieces[p].y = (pieces[p].y + pieces[p].dirY) % height;
        if(clock % 100 == 0 && piecesUsed < nPieces - 4){
          pieces[piecesUsed] = new Piece(pieces[p].x, pieces[p].y, pieces[p].dirX == 1 ? 0 : 1, pieces[p].dirY == 1 ? 0 : 1);
          piecesUsed += 4;
        }
        p++;
      }
    }
}

public class GrowingShapes extends Visual {
  
    int nShapes = 0;
    int maxShapes = 100;
    int direction = 1;
    int centerX = width/2;
    int centerY = height/2;
  
    public GrowingShapes(AudioSource[] str){
      super(str);
      pg = createGraphics(width, height);
    }
    
   
    public void updateGraphic(){
      pg.noFill();
      
      for (int s = 0; s < nShapes; s++){
         pg.beginShape();
         pg.strokeWeight(5);
         pg.stroke(sources[0].volume*2550, sources[1].volume*2550, sources[2].volume*2550);


        for (int deg = 0; deg <= 720; deg += 30){
          float rad = 100 + 20*s + sin(deg + s)*10;
          float cx = centerX + rad*sin(-(deg+clock/2)*PI/180);
          float cy = centerY + rad*cos(-(deg+clock/2)*PI/180);
          pg.curveVertex(cx, cy);
        }
        pg.endShape();

      }

    }
    
    public void updateFields(){
      if (sources[0].volume + sources[1].volume + sources[2].volume + sources[3].volume > 0.75){
        nShapes += direction;
        if(direction == 1 && nShapes == maxShapes){
          direction = -1;
        }
        else if (direction == -1 && nShapes == 0){
          direction = 1;
        } 
      }
    }
}

public class Waves extends Visual {
    PGraphics og;
    int nShapes = 0;
    int maxShapes = 20;
    int size = 25;
    int w = width/2;
    float base = (height - maxShapes*size)/2 + 50;
    Wave[] waves;
    
    public class Wave{
      Random rand = new Random();
      int nPoints = 50;
      float[] points;
      int ix;
      
      public Wave(float h, int idx){
        points = new float[nPoints];
        ix = idx;
        /*for (int x = 0; x < nPoints; x++){
          points[x] = h - rand.nextInt(parseInt(abs(sin(PI*x/nPoints))*(100 + 100*abs(sin(PI*(x/nPoints)))) + 1));
        }*/
        for (int x = 0; x < nPoints; x++){
          points[x] = h - sources[idx % nInputs].waveform[x]*500;
        }
      }
      
      public void draw(PGraphics p){
        switch(ix % nInputs){
          case 0:
            og.stroke(255);
            break;
          case 1:
            og.stroke(255,0,0);
            break;
          default:
            og.stroke(0,0,255);
        }
        
        og.noFill();
        og.strokeWeight(2);
        og.circle((width - w)/2, points[0], 5);
        og.circle(w + (width - w)/2, points[nPoints - 1], 5);
        og.beginShape();

        for (int x = 0; x < nPoints; x++){
          og.curveVertex((1.*x/(nPoints - 1))*w + (width - w)/2, points[x]);
        }
        
        og.endShape();
      }
    }
  
    public Waves(AudioSource[] str){
      super(str);
      waves = new Wave[maxShapes];
      pg = createGraphics(width, height);
      og = createGraphics(width, height);
    }
   
    public void updateGraphic(){
      og.beginDraw();
      og.background(0);
      for (int x = 0; x < nShapes; x++){
       waves[x % maxShapes].draw(pg);
      }
      og.endDraw();
      pg.loadPixels();
      og.loadPixels();
      pg.image(last, 0, 0);
      
      for(int x = 0; x < width; x++){
        for(int y = 0; y < height; y++){
          int offset = x + y*width;
          if(pg.get(x,y) != 0) pg.pixels[offset] = og.pixels[offset];
        }
      }
      
      pg.updatePixels();
    }
    
    public void updateFields(){
      nShapes = 0;
        for (int w = 0; w < maxShapes; w++){
          waves[w] = new Wave(base + w*size, w);
          nShapes++;
        }
    }
}

public class Waves2 extends Visual {
  
    int dist = 10;
    int size = width/2;
    int nDist = size/dist;

  
    public Waves2(AudioSource[] str){
      super(str);
      pg = createGraphics(width, height);
    }
   
    public void updateGraphic(){
      pg.background(0);
      pg.stroke(255);
      pg.noFill();
      pg.textAlign(CENTER);
      pg.textSize(40);
      //pg.text(name, width/2,  3*(height - size)/2 + size/6);
      for (int y = 0; y < nDist; y++){
       for (int x = 0; x < nDist; x++){
         pg.beginShape();
         float xval = x*dist + (width - size)/2;
         float yval = y*dist + (height - size)/2;
         yval += sin(x*y/((1+(sin(clock/50.)/2))*100.) + (clock + sources[0].volume*100)/10.)*10;
         yval -= size/6;

         //pg.vertex(xval, yval);
         if(x < nDist - 1){
           xval = (x+1)*dist + (width - size)/2;
           yval = y*dist + (height - size)/2;
           yval += sin((x+1)*y/((1+(sin(clock/50.)/2))*100.) + (clock + sources[0].volume*100)/10.)*10;
           yval -= size/6;

           pg.vertex(xval, yval);
           
           if(x > 0 && x < nDist - 1 && y < nDist - 1){
             xval = (x+1)*dist + (width - size)/2;
             yval = (y+1)*dist + (height - size)/2;
             yval += sin((x+1)*(y+1)/((1+(sin(clock/50.)/2))*100.) + (clock + sources[0].volume*100)/10.)*10;
             yval -= size/6;
             pg.vertex(xval, yval);
             xval = (x)*dist + (width - size)/2;
             yval = (y+1)*dist + (height - size)/2;
             yval += sin((x)*(y+1)/((1+(sin(clock/50.)/2))*100.) + (clock + sources[0].volume*100)/10.)*10;
             yval -= size/6;
             pg.vertex(xval, yval);
           }
         }
         if(x > 0 && x < nDist - 1){
           xval = x*dist + (width - size)/2;
           yval = y*dist + (height - size)/2;
           yval += sin(x*y/((1+(sin(clock/50.)/2))*100.) + (clock + sources[0].volume*100)/10.)*10;
           yval -= size/6;
           pg.vertex(xval, yval);
           pg.endShape();
         }
         

       }
       /*
         float xval = x*dist + (width - size)/2;
         float yval = y*dist + (height - size)/2;
         yval += sin(x*y/((1+(sin(clock/100.)/2))*100.) + clock/10.)*10;
         yval -= size/6;
         pg.curveVertex(xval, yval);
       }*/
       
      }
      
    }
    
}

public class KinectParent extends Visual {
    Kinect kinect;
    float[] depthLookUp = new float[2048];
    
    public KinectParent(AudioSource[] str, Kinect k){
      super(str);
      pg = createGraphics(width, height, P3D);
      kinect = k;
      kinect.initDepth();
      for (int i = 0; i < depthLookUp.length; i++) {
        depthLookUp[i] = rawDepthToMeters(i);
      }
    }
    
    // These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
    public float rawDepthToMeters(int depthValue) {
      if (depthValue < 2047) {
        return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
      }
      return 0.0f;
    }
    
    // Only needed to make sense of the ouput depth values from the kinect
    public PVector depthToWorld(int x, int y, int depthValue) {
    
      final double fx_d = 1.0 / 5.9421434211923247e+02;
      final double fy_d = 1.0 / 5.9104053696870778e+02;
      final double cx_d = 3.3930780975300314e+02;
      final double cy_d = 2.4273913761751615e+02;
    
    // Drawing the result vector to give each point its three-dimensional space
      PVector result = new PVector();
      double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
      result.x = (float)((x - cx_d) * depth * fx_d);
      result.y = (float)((y - cy_d) * depth * fy_d);
      result.z = (float)(depth);
      return result;
    }
}

public class Kinect001 extends KinectParent {
    int skip = 5;
    String an = "ADVERSARIALNETWORKS";
    int lan = 19; // length of string
    
    public Kinect001(AudioSource[] str, Kinect k){
      super(str, k);
    }
    
    public void updateGraphic(){
      pg.background(0);
      pg.stroke(255);
      pg.noFill();
      int currentLetter = parseInt(clock/100) % lan;
      int counter = 0;
      int[] depth = kinect.getRawDepth();
      for (int x = 0; x < kinect.width; x += skip) {
        for (int y = 0; y < kinect.height; y += skip) {
          int offset = x + y*kinect.width;
    
          // Convert kinect data to world xyz coordinate
          int rawDepth = depth[offset];
          PVector v = super.depthToWorld(x, y, rawDepth);
          if(rawDepth < 1500){
             pg.pushMatrix();
 
            int currentPosition = counter % lan;
            if(currentPosition == currentLetter){
              pg.fill(255,sources[0].spectrum[parseInt(bands*(1.*x/kinect.width))/8]*255,0);
              pg.textSize(sources[0].spectrum[parseInt(bands*(1.*x/kinect.width))/8]*100 + max(0, 25 - rawDepth/100));
              pg.text(an.substring(currentPosition, currentPosition + 1), v.x*220 + width/2 + sin(x/20. + clock/20.)*5, sin(clock/20.)*5 + v.y*220 + height/2);

            }
            else{
              pg.fill(255);
              pg.textSize(10);
              pg.text(an.substring(currentPosition, currentPosition + 1), v.x*220 + width/2, v.y*220 + height/2);
            }
            pg.popMatrix();
          }
         
          counter++;
        }
      }
    }  
}

public class Kinect002 extends KinectParent {
    BlobDetection blob;
    Random rand = new Random();
    int skip = 5;
    int factor = 1;
    String an = "ADVERSARIALNETWORKS";
    int lan = 19; // length of string
    PGraphics blubs;
    
    public Kinect002(AudioSource[] str, Kinect k){
      super(str, k);
      blubs = createGraphics(width, height, P3D);
      blob = new BlobDetection(k.width, k.height);
      blob.setPosDiscrimination(false);
      blob.setThreshold(0.5);
    }
    
    public void reset(){
      blubs = createGraphics(width, height, P3D);
      blob = new BlobDetection(kinect.width, kinect.height);
      blob.setPosDiscrimination(false);
      blob.setThreshold(0.5);
    }
    
    public void updateGraphic(){
      blubs.translate(0,0,clock);
      blubs.beginDraw();
      this.updateBlubs();
      blubs.endDraw();
      blubs.loadPixels();
      pg.loadPixels();
      
      for(int x = 0; x < width; x++){
        for(int y = 0; y < height; y++){
          int offset = x + y*width;
         
          
          if(x % 10 > 3 && clock % 100 < 50){
            pg.pixels[offset] = blubs.pixels[max(0, x + (y - floor(sources[0].volume*100))*width)];
          }
          else{
            pg.pixels[offset] = blubs.pixels[offset];/*blubs.pixels[min(width*height - 1, x + (y + floor(sources[0].volume*100))*width)];*/
           }
            
        }
      }
      
      pg.updatePixels();
      
    }
    
    public void updateBlubs(){
      PImage img = kinect.getDepthImage();
      int currentLetter = parseInt(clock/10.) % lan;
      blob.computeBlobs(img.pixels);
      blubs.strokeWeight(1);
      Blob b;
      EdgeVertex e;
      blubs.noFill();
      e = null;
      int counter = 0;
      for (int n = 0; n < blob.getBlobNb(); n ++) {
        b = blob.getBlob(n);
        if (b != null) {
          blubs.beginShape();
          for (int m = 0;m < b.getEdgeNb(); m ++) {
            //if(counter < clock*5){
              int currentPosition = counter % lan;
              if(currentPosition == currentLetter){
                blubs.stroke(2550*sin(clock)*sources[0].spectrum[n % bands], 2550*sin(clock)*sources[1].spectrum[n % bands], 2550*sin(clock)*sources[2].spectrum[n % bands]);
                blubs.textSize(8);
                e = b.getEdgeVertexA(m);
                //blubs.text(an.substring(currentPosition, currentPosition + 1), e.x*width, e.y*height, sin(clock)*100);
                blubs.curveVertex(e.x*width, e.y*height, sin(clock)*100);
              }
              /*else{
                pg.fill(155);
                pg.textSize(10);
              }*/
              
            //}
            counter++;
           
          }
          blubs.endShape();
        }
      }
    }
}

// AUDIO SOURCE CLASS
public class AudioSource {
  AudioIn au;
  Amplitude amp;
  FFT fft;
  int bufferSize = 50;
  int currentBuffer = 0;
  float[] spectrum;
  float volume;
  float[] waveform;
  float[][] fftwaves;
  
  public AudioSource(AudioIn i, Amplitude a, FFT f, float[] s){
    waveform = new float[bufferSize];
    fftwaves = new float[bufferSize][bands];
    
    au = i;
    amp = a;
    amp.input(au);
    
    fft = f;
    fft.input(au);
    
    spectrum = s;
    
    au.start();
  }
  
  public void update(){
    this.updateVolume();
    this.updateFFT();
    this.updateBuffer();
  }

  public void updateVolume(){
    volume = amp.analyze();
  }
  
  public void updateFFT(){
    fft.analyze(spectrum);
  }
  
  public void updateBuffer(){
    waveform[currentBuffer] = this.volume;
    for(int b = 0; b < bands; b++){
      fftwaves[currentBuffer][b] = this.spectrum[b];
    }
    currentBuffer = (currentBuffer + 1) % bufferSize;

  }
}






AudioSource[] sources = new AudioSource[nInputs];
Visual[] visuals = new Visual[nVisuals];

HashMap<String, Integer> inputMap = new HashMap<String, Integer>();


void setup(){
  size(1000, 1000, P3D);
  //fullScreen(P3D, 1);
  smooth();
  kin = new Kinect(this);
  
  // SETUP INPUTS
  inputMap.put("MOD", 0);
  inputMap.put("GTR", 1);
  inputMap.put("KEY", 2);
  
  for (int n = 0; n < nInputs; n++){
    AudioIn a = new AudioIn(this, n);
    Amplitude b = new Amplitude(this);
    FFT c = new FFT(this, bands);
    float[] d = new float[bands];
    
    sources[n] = new AudioSource(a, b, c, d);
  }
  
  
  visuals[0] = new StarField(sources, true);
  visuals[1] = new Kinect002(sources, kin);
  visuals[2] = new StarField(sources, false);
  visuals[3] = new Waves(sources);
  visuals[7] = new LineGeom(sources);
  visuals[4] = new GrowingShapes(sources);
  visuals[5] = new Waves2(sources);
  visuals[6] = new Kinect001(sources, kin);

  
  background(0);
  
}

void draw(){
  try{
    currentGraphic = visuals[currentVisual].step();
    image(currentGraphic, 0,0);
    clock++;
  }
  catch (Exception e){
    setup();
  }
    
}

void keyReleased() {
  if (key == 'd') {
    currentVisual = (currentVisual + 1) % nVisuals;
    clock = 0;
    visuals[currentVisual].reset();
    if(currentVisual == 3){
      visuals[currentVisual].setLast(visuals[2].pg);
    }
  } else if (key == 'a'){
    currentVisual--;
    clock = 0;
    if (currentVisual < 0) currentVisual = nVisuals - 1;
    visuals[currentVisual].reset();
    if(currentVisual == 3){
      visuals[currentVisual].setLast(visuals[4].pg);
    }
  }
}