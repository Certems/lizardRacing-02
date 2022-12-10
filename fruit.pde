/*
System 1;
Fruit released all at once on the map, lizards compete to get as many as they can from the shared pool
Any who get fruit live

System 2;
Fruit released one at a time, and separate for each lizard, so all have to go to same 'spawn spots' in same
order.


##
## KEEP FOR NOW AS LARGE FLAG ZONES WITH LOTS OF LIZARDS, WINNERS IF TOUCH A FLAG, SCORE FOR EACH FLAG +/ DISTANCE
##
*/

class fruit{
    PVector pos;

    boolean eaten = false;

    float r;

    fruit(PVector position, float detectRadius){
        pos = position;
        r   = detectRadius;
    }

    void display(){
        displayFruit();
        displayCollision();
    }
    void displayFruit(){
        pushStyle();
        fill(190, 220, 100);
        stroke(255);
        strokeWeight(1);
        ellipse(pos.x, pos.y, 5,5);
        popStyle();
    }
    void displayCollision(){
        pushStyle();
        noFill();
        stroke(255);
        strokeWeight(2);
        ellipse(pos.x, pos.y, 2.0*r,2.0*r);
        popStyle();
    }
    void checkCollision(lizard lEntity){
        boolean close = vecDist(pos, lEntity.body.get(0).pos) <= r;
        if( close && !eaten ){
            eaten = true;
            lEntity.score+=1;
        }
    }
}