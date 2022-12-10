/*
Build such that can be adapted to C, so processing can just handle display of the simulation
C used to calculate values and store in txt document

NOTES;
------
Try;    Upping number of hidden networks
        Making scoreSpace vary with roundNumber / score Total
        Making more / less lizards spawn so fewer random lizards are made

        MAKE THEM USE ARRAY OUTPUT TO DO MULTIPLE ACTIONS
        NEVER MOVING UP
*/
void setup(){
    fullScreen();//size(800,800);

    initStandardNetwork();

    createInitialLizards(lizardNumber, standardSize, standardLength);
    fillFruitPosSets();
    createFruitFlags(fruitNumber, fruitDetectRad);
}
void draw(){
    if(!showGraph){
        //situation1();
        //situation2();
        situation3();
    }
    else{
        displayBackground();
        plotRoundScores();
    }
}

void keyPressed(){
    //## MOVE THESE INTO ANOTHER FUNCTION TO HANDLE LIZARD CONTROLS ##
    //## OR JUST REMOVE AND USE ONLY AS BUG FIXING ##
    if(key == '1'){
        lowPolyMode = !lowPolyMode;
    }
    if(key == 'w'){
        lizards.get(0).accelerate = true;
    }
    if(key == 's'){
        lizards.get(0).brake = true;
    }
    if(key == 'a'){
        lizards.get(0).turnLeft = true;
    }
    if(key == 'd'){
        lizards.get(0).turnRight = true;
    }
    if(key == '2'){
        frameSkip -= 3;
    }
    if(key == '3'){
        frameSkip += 3;
    }
    if(key == '4'){
        showGraph = !showGraph;
    }
    if(key == '5'){
        showScoreSpace = !showScoreSpace;
    }
}
void keyReleased(){
    if(key == 'w'){
        lizards.get(0).accelerate = false;
    }
    if(key == 's'){
        lizards.get(0).brake = false;
    }
    if(key == 'a'){
        lizards.get(0).turnLeft = false;
    }
    if(key == 'd'){
        lizards.get(0).turnRight = false;
    }
}
