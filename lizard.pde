/*
Manages the drawing of the lizard
Should be able to work with raw data given and read too
Procedural mark placment -> bounding zone for placement to make loop more interesting, multiple joints??
*/

class lizard{
    network brain;

    ArrayList<bodyPiece> body = new ArrayList<bodyPiece>();

    PVector dir;

    boolean turnLeft    = false;
    boolean turnRight   = false;
    boolean accelerate  = false;
    boolean brake       = false;
    
    //
    boolean up      = false;
    boolean down    = false;
    boolean left    = false;
    boolean right   = false;
    //

    float score = 0;

    float r;
    float m = 1.0;          //Not particularly important, therefore just set for all
    float fThrust = 0.0;
    float fBrakes = 0.2;
    float groundCoeff   = 0.1;
    float turnSpd       = PI / 128.0;
    float thrustRate    = 0.001;
    float fCoeff = 0.1;

    lizard(int bodySize, PVector bodyOrigin, float naturalLength, PVector lookDirection, network givenNetwork){
        r   = naturalLength;    //Length for which pieces will try to space themselves / be pulled after exceeding
        dir = lookDirection;    //Direction lizard accelerates (head)
        createBody(bodySize, bodyOrigin);
        brain = givenNetwork;
        body.get(0).vel = new PVector( random(0,10), random(0,10) );
    }

    void display(){
        displayPieces();
        if(!lowPolyMode){
        displayConnected();
        displayLines();}
    }
    void displayPieces(){
        /*
        Individual segments
        */
        if(!lowPolyMode){
        displayBody();
        displayHead();}
        displayHeadPoint();
    }
    void displayHead(){
        pushStyle();
        fill(body.get(0).col.x, body.get(0).col.y, body.get(0).col.z);
        stroke(255);
        ellipse(body.get(0).pos.x, body.get(0).pos.y, 10, 10);
        popStyle();
    }
    void displayHeadPoint(){
        pushStyle();
        fill(255);
        stroke(255);
        point(body.get(0).pos.x, body.get(0).pos.y);
        popStyle();
    }
    void displayBody(){
        for(int i=1; i<body.size(); i++){
            body.get(i).display();
        }
    }
    void displayConnected(){
        /*
        Connected line across body
        */
        pushStyle();
        noFill();
        stroke(255);
        strokeWeight(3);
        beginShape();
        curveVertex(body.get(0).pos.x, body.get(0).pos.y);
        for(int i=0; i<body.size(); i++){
            curveVertex(body.get(i).pos.x, body.get(i).pos.y);
        }
        curveVertex(body.get( body.size()-1 ).pos.x, body.get( body.size()-1 ).pos.y);
        endShape();
        popStyle();
    }
    void displayLines(){
        /*
        Displays the vel, acc and dir
        */
        float dirLen = 20.0;
        pushStyle();
        strokeWeight(2.0);
        //Vel
        stroke(255,0,0);
        line(body.get(0).pos.x, body.get(0).pos.y,      body.get(0).pos.x +body.get(0).vel.x*dirLen, body.get(0).pos.y +body.get(0).vel.y*dirLen);
        //Acc
        stroke(0,255,0);
        line(body.get(0).pos.x, body.get(0).pos.y,      body.get(0).pos.x +body.get(0).acc.x*dirLen, body.get(0).pos.y +body.get(0).acc.y*dirLen);
        //Dir
        stroke(0,0,255);
        line(body.get(0).pos.x, body.get(0).pos.y,      body.get(0).pos.x +dir.x*dirLen, body.get(0).pos.y +dir.y*dirLen);
        popStyle();
    }
    void updateActionAi(){
        //## CONSIDERING 0 AS ALL FRUITS AT SAME POS HERE, and not considering whether eaten or not
        int action = brain.runNetwork(this, sys2Fruits.get(0).get(int(score)));

        /*
        turnLeft    = false;
        turnRight   = false;
        accelerate  = false;
        brake       = false;

        if(action == 0){
            turnLeft = true;}
        if(action == 1){
            turnRight = true;}
        if(action == 2){
            accelerate = true;}
        if(action == 3){
            brake = true;}
        */

        //
        up      = false;
        down    = false;
        left    = false;
        right   = false;

        if(action == 0){
            up      = true;}
        if(action == 1){
            down    = true;}
        if(action == 2){
            left    = true;}
        if(action == 3){
            right   = true;}
        //
    }
    void updateState(){
        /*
        Updates what is being performed
        */
        /*
        fCoeff = groundCoeff;
        if(turnLeft){
            rotateCCW(turnSpd);
        }
        if(turnRight){
            rotateCW(turnSpd);
        }
        if(accelerate){
            accInDir();
        }
        if(brake){
            brakeOpDir();
        }
        decayThrust();
        */
        //
        float moveDist = 0.1;
        if(up){
            body.get(0).vel.y -= moveDist;}
        if(down){
            body.get(0).vel.y += moveDist;}
        if(left){
            body.get(0).vel.x -= moveDist;}
        if(right){
            body.get(0).vel.x += moveDist;}
        //        
    }
    void rotateCCW(float spd){
        /*
        Matrix rotation to turn dir vec
        */
        dir.x = dir.x*cos(-spd) - dir.y*sin(-spd);
        dir.y = dir.x*sin(-spd) + dir.y*cos(-spd);
    }
    void rotateCW(float spd){
        /*
        Matrix rotation to turn dir vec
        */
        dir.x = dir.x*cos(spd) - dir.y*sin(spd);
        dir.y = dir.x*sin(spd) + dir.y*cos(spd);
    }
    void accInDir(){
        fThrust += thrustRate;
    }
    void brakeOpDir(){
        for(int i=0; i<2; i++){ //Another 'stack' of decaying
            decayThrust();
        }
    }
    void decayThrust(){
        fThrust -= thrustRate/3.0;
        if(fThrust < 0.0){
            fThrust = 0.0;
        }
    }
    void createBody(int n, PVector orig){
        /*
        Creates body of given size semi-randomly at a given starting point (for its head)
        oTheta = offset angle, for the whole body
        rTheta = range for dTheta
        dTheta = change in angle for each segment
        */
        PVector nextPiece = new PVector(orig.x, orig.y);
        float oTheta = random(0,2.0*PI);
        float rTheta = PI / 8.0;
        for(int i=0; i<n; i++){
            float dTheta = random(-rTheta, rTheta);
            PVector newPos = new PVector(nextPiece.x +r*cos(dTheta+oTheta), nextPiece.y +r*sin(dTheta+oTheta));
            bodyPiece newBodyPiece = new bodyPiece( new PVector(newPos.x, newPos.y) );
            body.add( newBodyPiece );
            nextPiece = new PVector(newPos.x, newPos.y);
        }
    }
    void calcDynamics(){
        calcForce();
        calcAcc();
        calcVel();
        calcPos();
    }
    void calcForce(){
        calcHeadForce();
    }
    void calcAcc(){
        calcHeadAcc();
    }
    void calcVel(){
        calcHeadVel();
        calcBodyVel();
    }
    void calcPos(){
        calcHeadPos();
        calcBodyPos();
    }
    void calcHeadForce(){
        body.get(0).force.x = 0;
        body.get(0).force.y = 0;
        //Thrust
        body.get(0).force.x += fThrust *dir.x;
        body.get(0).force.y += fThrust *dir.y;
        //Friction
        body.get(0).force.x -= fCoeff *body.get(0).vel.x;
        body.get(0).force.y -= fCoeff *body.get(0).vel.y;
    }
    void calcHeadAcc(){
        body.get(0).acc.x = body.get(0).force.x / m;
        body.get(0).acc.y = body.get(0).force.y / m;
    }
    void calcHeadVel(){
        body.get(0).vel.x += body.get(0).acc.x;
        body.get(0).vel.y += body.get(0).acc.y;

        fixVel();
    }
    void calcHeadPos(){
        body.get(0).pos.x += body.get(0).vel.x;
        body.get(0).pos.y += body.get(0).vel.y;
    }
    void calcBodyVel(){
        for(int i=1; i<body.size(); i++){
            if(isStretched(i)){
                PVector nextDir = vecNormalise( new PVector(body.get(i-1).pos.x - body.get(i).pos.x, body.get(i-1).pos.y - body.get(i).pos.y) );
                body.get(i).vel.x = vecMag(body.get(i-1).vel) *nextDir.x;
                body.get(i).vel.y = vecMag(body.get(i-1).vel) *nextDir.y;
            }
            else{
                body.get(i).vel.x = 0.0;
                body.get(i).vel.y = 0.0;
            }
        }
    }
    void calcBodyPos(){
        for(int i=1; i<body.size(); i++){
            body.get(i).pos.x += body.get(i).vel.x;
            body.get(i).pos.y += body.get(i).vel.y;
        }
    }
    void fixVel(){
        float minVel =  0.4;
        float maxVel = 10.0;
        if( vecMag(body.get(0).vel) < minVel ){
            //body.get(0).vel.x = minVel*dir.x;
            //body.get(0).vel.y = minVel*dir.y;
        }
        if( vecMag(body.get(0).vel) > maxVel ){
            body.get(0).vel.x = maxVel*dir.x;
            body.get(0).vel.y = maxVel*dir.y;
        }
    }
    boolean isStretched(int nPiece){
        float dist = vecDist(body.get(nPiece).pos, body.get(nPiece-1).pos);
        return (dist > r);
    }
}

class bodyPiece{
    PVector col     = new PVector(180, 180, 110);
    PVector pos;
    PVector vel     = new PVector(0,0);
    PVector acc     = new PVector(0,0);
    PVector force   = new PVector(0,0);

    bodyPiece(PVector position){
        pos = position;
    }

    void display(){
        pushStyle();
        fill(col.x, col.y, col.z);
        stroke(255);
        ellipse(pos.x, pos.y, 10, 10);
        popStyle();
    }
}