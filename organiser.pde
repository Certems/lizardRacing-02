/*
Collection of random / linking functions
Helps to keep other spaces clear

0. Misc
1. Lizard functions
2. Fruit   " "
3. Networks
4. Game loop
*/

//0
void situation1(){
    //Standard version
    displayBackground();

    updateAllLizardAi();
    calcFruit();
    calcLizards();

    roundDecider();

    colBugChecker();

    if(showScoreSpace){
        scoreSpace();}
    overlay();
}
void situation2(){
    //Quicker version
    displayBackground();
    for(int i=0; i<frameSkip; i++){
        updateAllLizardAi();
        updateFruit();
        updateLizards();

        roundDecider();
    }
    //showAllFruit();
    showLizards();

    pushStyle();
    line(width/2.0, 0, width/2.0, height);
    popStyle();

    colBugChecker();

    if(showScoreSpace){
        scoreSpace();}
    overlay();
}
void situation3(){
    //Insane version
    displayBackground();
    for(int i=0; i<frameSkip; i++){
        updateAllLizardAi();
        updateFruit();
        updateLizards();

        roundDecider();
    }
    if(roundNumber > wantedRound){
        //showAllFruit();
        frameSkip = 1;
        showLizards();

        colBugChecker();

        if(showScoreSpace){
            scoreSpace();}
        overlay();
    }
    else{
        showProgressBar();
    }
}
void displayBackground(){
    background(90, 60, 120);
}
void overlay(){
    /*
    Shows;
    . Framerate
    . Round number
    . Round time
    . Round time max
    */
    pushStyle();
    fill(255);
    text(frameRate, 30,30);

    text("Round #;      "+roundNumber, 30,60);

    text("Current time; "+roundTime, 30,90);

    text("Max time;     "+timeMax, 30,120);
    popStyle();
}
float vecDist(PVector v1, PVector v2){
    return sqrt( pow(v1.x - v2.x,2) + pow(v1.y - v2.y,2) );
}
float vecMag(PVector v){
    return sqrt( pow(v.x,2) + pow(v.y,2) );
}
PVector vecNormalise(PVector v){
    float mag = vecMag(v);
    if(mag != 0){
        return new PVector( (1.0 / mag)*v.x, (1.0 / mag)*v.y );
    }
    else{
        return new PVector(0,0);
    }
}
void initStandardNetwork(){
    stdNetwork.add(3);
    stdNetwork.add(4);
    stdNetwork.add(4);
    stdNetwork.add(4);
    stdNetwork.add(4);
    stdNetwork.add(4);
}
void showProgressBar(){
    float maxWidth   = width/3.0;
    float maxHeight  = height/18.0;
    float sText      = maxHeight /3.0;
    float multiplier = float(roundNumber) / float(wantedRound);
    pushStyle();
    rectMode(CORNER);
    textSize(sText);
    //Box outline
    fill(0);
    strokeWeight(4);
    rect(width/2.0 - maxWidth/2.0, height/2.0 - maxHeight/2.0, maxWidth, maxHeight);
    //Box fill
    fill(255);
    strokeWeight(1);
    rect(width/2.0 - maxWidth/2.0, height/2.0 - maxHeight/2.0, maxWidth*multiplier, maxHeight);
    //Percentage value
    stroke(0);
    fill(0);
    text(round(100.0*multiplier) , width/2.0 - maxWidth/2.0 + maxWidth*multiplier -2.5*sText, height/2.0 + maxHeight/4.0);
    text("%" , width/2.0 - maxWidth/2.0 + maxWidth*multiplier -2.5*sText +1.5*sText, height/2.0 + maxHeight/4.0);
    popStyle();
}

//1
lizard generateLizard(int sze, PVector orig, float l, network linkedNet){
    /*
    Creates a lizard at a given point
    */
    float rVal = random(0,2.0*PI);
    lizard newLizard = new lizard(sze, orig, l, new PVector(cos(rVal), sin(rVal)), linkedNet);
    return newLizard;
}
void calcLizards(){
    showLizards();
    updateLizards();
}
void showLizards(){
    /*
    Draws all lizards
    */
    for(int i=0; i<lizards.size(); i++){
        lizards.get(i).display();
    }
}
void updateLizards(){
    /*
    Calculates lizard motion
    */
    for(int i=0; i<lizards.size(); i++){
        lizards.get(i).calcDynamics();
        lizards.get(i).updateState();
    }
}
void updateAllLizardAi(){
    //#####################################################
    //## CAN PUT "int i=1" instead, so 0 is controllable ##
    //#####################################################
    for(int i=0; i<lizards.size(); i++){
        lizards.get(i).updateActionAi();
    }
}

//2
void calcFruit(){
    showAllFruit();
    updateFruit();
}
void showAllFruit(){
    for(int i=0; i<sys2Fruits.get(0).size(); i++){
        sys2Fruits.get(0).get(i).display();
        pushStyle();
        textSize(20);
        text(i, sys2Fruits.get(0).get(i).pos.x, sys2Fruits.get(0).get(i).pos.y);
        popStyle();
    }
}
void updateFruit(){
    for(int i=0; i<lizards.size(); i++){
        for(int j=0; j<sys2Fruits.get(i).size(); j++){
            if(!sys2Fruits.get(i).get(j).eaten){
                sys2Fruits.get(i).get(j).checkCollision( lizards.get(i) );
                break;
            }
        }
    }
}
void fillFruitPosSets(){
    //For 8 fruit
    fruitPosSets.add( new PVector(eOffset,eOffset) );
    fruitPosSets.add( new PVector(width-eOffset,height-eOffset) );
    fruitPosSets.add( new PVector(width/2.0,eOffset) );
    fruitPosSets.add( new PVector(width/2.0,height-eOffset) );
    fruitPosSets.add( new PVector(width-eOffset,eOffset) );
    fruitPosSets.add( new PVector(eOffset,height-eOffset) );
    fruitPosSets.add( new PVector(eOffset,height/2.0) );
    fruitPosSets.add( new PVector(width-eOffset,height/2.0) );
}
void createFruitFlags(int fruitNum, float detectRad){
    sys2Fruits.clear();
    for(int i=0; i<lizards.size(); i++){
        sys2Fruits.add( new ArrayList<fruit>() );
    }
    for(int i=0; i<lizards.size(); i++){
        for(int j=0; j<fruitNum; j++){
            PVector pos = new PVector(fruitPosSets.get(j).x, fruitPosSets.get(j).y);
            fruit newFruit = new fruit(pos, detectRad);
            sys2Fruits.get(i).add(newFruit);
        }
    }
}

//3
/*
void displayNetworks(){
    for(int p=0; p<lizards.size(); p++){
        //
        for(int i=0; i<lizards.get(p).brain.net.size(); i++){
            lizards.get(p).brain.net.
            for(int j=0; j<lizards.get(p).brain.get(i).size(); j++){
                //pass
            }
        }
        //
    }
}
*/

//4
void createInitialLizards(int nLizards, int sze, float l){
    for(int i=0; i<nLizards; i++){
        network newNetwork = new network(stdNetwork);
        newNetwork.randomiseNet(1.0);
        PVector newPos = new PVector( random(0,width), random(0,height) );
        lizard newLizard = generateLizard(sze, new PVector(newPos.x, newPos.y), l, newNetwork);
        lizards.add(newLizard);
    }
}
void roundDecider(){
    /*
    Chooses when to end rounds and reset for next round
    */
    boolean roundOver = (roundTime >= timeMax);
    if(roundOver){
        resetRound();
        roundNumber++;
        roundTime = 0;
    }
    roundTime++;
}
void resetRound(){
    /*
    Resets round variables
    . Merges winning networks
    . Creates new lizards with these new networks
    . Places new fruit down
    */
    recordRoundScores();
    ArrayList<ArrayList<network>> newNetSet = createWinPairings( findWinners() );
    ArrayList<ArrayList<Float>> newScoreSet = createScorePairings( findWinnerLizards() );
    formNewLizards(newNetSet, newScoreSet, standardSize, standardLength);
    createFruitFlags(fruitNumber, fruitDetectRad);
}
//#######################################
//## WINNERS NEED TO BE MORE SELECTIVE ##
//#######################################
//######################################
//## Merge both winner things somehow ##
//######################################
ArrayList<network> findWinners(){
    /*
    Returns list of the winning networks
    */
    ArrayList<network> winNets = new ArrayList<network>();
    ArrayList<Float> assosciatedScore = new ArrayList<Float>();
    for(int i=0; i<lizards.size(); i++){
        if(findScore(lizards.get(i)) > 0){         //## NEED TO ADJUST WHEN DISTANCE IS INTRODUCED TO SCORE    ##
            winNets.add( lizards.get(i).brain );   //## CAREFUL IS NOT BY REFERENCE                            ##
            assosciatedScore.add( findScore(lizards.get(i)) );
        }
    }
    //Sort list
    for(int i=0; i<winNets.size(); i++){
        boolean switched = false;
        for(int j=0; j<winNets.size()-1; j++){
            if( assosciatedScore.get(j+1) > assosciatedScore.get(j) ){
                network switchNet = winNets.get(j+1);
                float switchScore = assosciatedScore.get(j+1);
                winNets.remove(j+1);
                assosciatedScore.remove(j+1);
                winNets.add(j, switchNet);
                assosciatedScore.add(j, switchScore);
                switched = true;
            }
        }
        if(!switched){
            break;
        }
    }
    return winNets;
}
ArrayList<lizard> findWinnerLizards(){
    /*
    Returns list of the winning networks
    */
    ArrayList<lizard> winLiz = new ArrayList<lizard>();
    for(int i=0; i<lizards.size(); i++){
        if(findScore(lizards.get(i)) > 0){         //## NEED TO ADJUST WHEN DISTANCE IS INTRODUCED TO SCORE    ##
            winLiz.add( lizards.get(i) );    //## CAREFUL IS NOT BY REFERENCE                            ##
        }
    }
    //Sort list
    for(int i=0; i<winLiz.size(); i++){
        boolean switched = false;
        for(int j=0; j<winLiz.size()-1; j++){
            if( findScore(winLiz.get(j+1)) > findScore(winLiz.get(j)) ){
                lizard switchLiz = winLiz.get(j+1);
                winLiz.remove(j+1);
                winLiz.add(j, switchLiz);
                switched = true;
            }
        }
        if(!switched){
            break;
        }
    }
    return winLiz;
}
ArrayList<ArrayList<Float>> createScorePairings(ArrayList<lizard> winLiz){
    ArrayList<ArrayList<Float>> pairings = new ArrayList<ArrayList<Float>>();
    if(winLiz.size() > 0)
    {
        for(int i=0; i<winLiz.size(); i+=2){
            boolean next2exist = i+2 < winLiz.size();
            if(next2exist){
                pairings.add(new ArrayList<Float>());
                pairings.get(pairings.size()-1).add( findScore(winLiz.get(i  )) );
                pairings.get(pairings.size()-1).add( findScore(winLiz.get(i+1)) );
            }
            else{
                if(winLiz.size() == 1){
                    pairings.add(new ArrayList<Float>());
                    pairings.get(0).add( findScore(winLiz.get(0)) );
                }
                else{
                    pairings.get(pairings.size()-1).add( findScore(winLiz.get(i  )) );
                }
            }
        }
    }
    return pairings;
}
ArrayList<ArrayList<network>> createWinPairings(ArrayList<network> winNets){
    /*
    Takes all winners and splits them into groups, which are then used to spawn new lizards
    . Pairs if possible -> 3 if odd number
    . Ignore if 1 wins
    */
    ArrayList<ArrayList<network>> pairings = new ArrayList<ArrayList<network>>();
    if(winNets.size() > 0)
    {
        for(int i=0; i<winNets.size(); i+=2){
            boolean next2exist = i+2 < winNets.size();
            if(next2exist){
                pairings.add(new ArrayList<network>());
                pairings.get(pairings.size()-1).add(winNets.get(i  ));
                pairings.get(pairings.size()-1).add(winNets.get(i+1));
            }
            else{
                if(winNets.size() == 1){
                    pairings.add(new ArrayList<network>());
                    pairings.get(0).add(winNets.get(0));
                }
                else{
                    pairings.get(pairings.size()-1).add(winNets.get(i  ));
                }
            }
        }
    }
    return pairings;
}
//##
//## SORT BUY SCORE, SPAWN EXPONENTIALLY
//##
void formNewLizards(ArrayList<ArrayList<network>> pairings, ArrayList<ArrayList<Float>> scorePairs, int sze, float l){
    int lizMaxProduce = 35;
    ArrayList<lizard> lizardsBuffer = new ArrayList<lizard>();
    //Reduce Number of Winners
    float totalPairs = pairings.size();
    for(int i=0; i<ceil(totalPairs*0.65); i++){
        pairings.remove(pairings.size()-1);
        scorePairs.remove(scorePairs.size()-1);
    }
    //
    for(int i=0; i<pairings.size(); i++){
        float scoreTot = 0;
        for(int p=0; p<scorePairs.get(i).size(); p++){
            scoreTot += scorePairs.get(i).get(p);}
        scoreTot /= scorePairs.get(i).size();
        int bound = floor(exp(scoreTot));
        if(bound > lizMaxProduce){
            bound = lizMaxProduce;}
        //println("BOUND ->",bound);
        //println("SCOREtot -> ",scoreTot);
        int rVal  = ceil(random(ceil(6.0*bound/10.0),bound));
        if(lizardsBuffer.size() < lizardNumber)
        {
            for(int j=0; j<rVal; j++){
                network newNetwork = new network(stdNetwork);
                PVector newPos = new PVector( random(0,width), random(0,height) );
                lizard newLizard = generateLizard(sze, new PVector(newPos.x, newPos.y), l, newNetwork);
                newLizard.brain.mergeNet(pairings.get(i), scorePairs.get(i));
                lizardsBuffer.add(newLizard);
            }
        }
    }
    lizards.clear();
    for(int i=0; i<lizardsBuffer.size(); i++){
        lizards.add(lizardsBuffer.get(i));
    }
    fillRemainingLizardsFresh();
}
void fillRemainingLizardsFresh(){
    //println("freshLizards -> ",lizardNumber-lizards.size());    //## CHECK IF IS TOO HIGH
    if(lizards.size() < lizardNumber){
        createInitialLizards(lizardNumber-lizards.size(), standardSize, standardLength);
    }
}
float findScore(lizard l){
    //y = e^(-x)
    /*
    float distScaler = 100.0;
    float distScore  = pow(exp(1), -1.0*( (vecDist(l.body.get(0).pos, sys2Fruits.get(0).get(int(l.score)).pos) -sys2Fruits.get(0).get(int(l.score)).r) / distScaler ));
    float flagScore  = l.score;
    float boundaryPunish = boundaryScoreLoss(l);
    float finalScore = distScore + flagScore + boundaryPunish;
    return finalScore;
    */
    float score = 0;
    score += 7.0*Math.tanh( ((l.body.get(0).pos.x)-(width/2.0))/1000.0 );
    float nWidth  = 0.9*width;
    float nHeight = 0.9*height;
    if( ((l.body.get(0).pos.x < 0) || (l.body.get(0).pos.x > nWidth)) || ( (l.body.get(0).pos.y < 0) || (l.body.get(0).pos.y > nHeight) ) ){
        score = 0;
        score -= exp( (min( abs(l.body.get(0).pos.x -0), abs(l.body.get(0).pos.x -nWidth ) )) / 600.0 );        //#########################################################################
        score -= exp( (min( abs(l.body.get(0).pos.y -0), abs(l.body.get(0).pos.y -nHeight) )) / 600.0 );        //## Scale with round number
        //Starts very easy, just go to right, then gets harder
    }
    return score;
}
float boundaryScoreLoss(lizard l){
    float scaleFac = 10.0;
    float loss = (1.2*height - vecDist(l.body.get(0).pos, new PVector(0,0))) / scaleFac;
    if(loss < 0){
        return loss;
    }
    else{
        return 0;
    }
}



void colBugChecker(){
    for(int i=0; i<lizards.size(); i++){
        if(lizards.get(i).score >= 1){
            lizards.get(i).body.get(0).col = new PVector(255,0,0);
        }
        if(lizards.get(i).score >= 2){
            lizards.get(i).body.get(1).col = new PVector(0,255,0);
        }
        if(lizards.get(i).score >= 3){
            lizards.get(i).body.get(2).col = new PVector(0,0,255);
        }
        if(lizards.get(i).score >= 4){
            lizards.get(i).body.get(3).col = new PVector(240,70,20);
        }
        //...
    }
}
float findWinnerScoreTotalPerLizard(ArrayList<lizard> winnerLizards){
    float scoreRunningTotal = 0;
    for(int i=0; i<winnerLizards.size(); i++){
        scoreRunningTotal += findScore( winnerLizards.get(i) );
    }
    scoreRunningTotal /= winnerLizards.size();
    return scoreRunningTotal;
}
void recordRoundScores(){
    float roundScore = findWinnerScoreTotalPerLizard( findWinnerLizards() );
    roundScores.add( roundScore );
}
void plotRoundScores(){
    float xMax = roundScores.size();
    float yMax = 5.0;
    float xInc = (width *0.8) / xMax;
    float yInc = (height*0.8) / yMax;

    pushStyle();
    textAlign(CENTER);
    fill(255);
    stroke(255);
    strokeWeight(2);
    //Draw axis
    line(width*0.1, height*0.9, width*0.9, height*0.9);
    line(width*0.1, height*0.9, width*0.1, height*0.1);

    //Draw increments
    rectMode(CENTER);
    int textDrawStep = ceil(roundScores.size() / 10.0);
    int cycleNum = 0;
    for(float i=width*0.1; i<width*0.9; i+=xInc){
        rect(i,height*0.9, xInc/10.0,xInc/10.0);
        if(cycleNum % textDrawStep == 0){
            text(cycleNum , i,height*0.95);
        }
        cycleNum++;
    }
    textDrawStep = 1;
    cycleNum = 0;
    for(float i=height*0.9; i>height*0.1; i-=yInc){
        rect(width*0.1, i, yInc/10.0,yInc/10.0);
        if(cycleNum % textDrawStep == 0){
            text(cycleNum , width*0.05, i);
        }
        cycleNum++;
    }

    //Draw data points
    for(int i=0; i<roundScores.size(); i++){
        ellipse(width*0.1 +i*xInc, height*0.9 -roundScores.get(i)*yInc, xInc*0.5,xInc*0.5);
    }

    //Comparison line
    stroke(255);
    strokeWeight(2);
    line(0,mouseY, width,mouseY);

    popStyle();
}

void scoreSpace(){
    float sWidth    = 1920.0;   //Set to larger values than the width and height to see a larger window of the score space
    float sHeight   = 1080.0;   //e.g try (2880,1620)
    float inc = 60.0;
    float incX = inc;
    float incY = inc;
    float maxScore = 20.0;

    float dx = (sWidth - width)/2.0;
    float dy = (sHeight - height)/2.0;
    pushStyle();
    textSize(10);

    for(float i=0-dx; i<width+dx; i+=incX){
        for(float j=0-dy; j<height+dy; j+=incY){
            lizard testLizard = generateLizard(1, new PVector(i,j), 1.0, new network(stdNetwork));
            float testScore = findScore(testLizard);
            if(testScore < 0){
                fill(255*(-testScore*1.5),0,0);
            }
            else{
                fill(0,255*(testScore/maxScore),0);
            }
            text(testScore, (i+dx)*(width/sWidth), (j+dy)*(height/sHeight));
            //ellipse((i+dx)*(width/sWidth), (j+dy)*(height/sHeight), incX/2.0,incY/2.0);
        }
    }

    popStyle();
}