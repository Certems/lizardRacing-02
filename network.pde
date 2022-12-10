class network{
    ArrayList<ArrayList<node>> net = new ArrayList<ArrayList<node>>();

    network(ArrayList<Integer> networkSize){
        createBlank(networkSize);
    }
    
    void display(){
        //pass
    }
    void createBlank(ArrayList<Integer> netSize){
        net.clear();
        for(int i=0; i<netSize.size(); i++){
            net.add( new ArrayList<node>() );
            for(int j=0; j<netSize.get(i); j++){
                node newNode = new node();
                net.get(i).add( newNode );
                net.get(i).get(j).bias = 0.0;
                if(i != netSize.size() -1){
                for(int z=0; z<netSize.get(i+1); z++){
                    net.get(i).get(j).weights.add(0.0);
                }
                }
            }
        }
    }
    void randomiseNet(float rFactor){
        for(int i=0; i<net.size(); i++){
            for(int j=0; j<net.get(i).size(); j++){
                float newBias = net.get(i).get(j).bias + random(-rFactor, rFactor);
                net.get(i).get(j).bias = newBias;
                for(int z=0; z<net.get(i).get(j).weights.size(); z++){
                    float newWeight = net.get(i).get(j).weights.get(z) + random(-rFactor, rFactor);
                    net.get(i).get(j).weights.remove(z);
                    net.get(i).get(j).weights.add(z, newWeight);
                }
            }
        }
    }
    void mergeNet(ArrayList<network> mNets, ArrayList<Float> mScores){  
        /*
        Merges mNets together weighted by score
        #########################################
        ## EXPERIMENT WITH DIFFERENT MUTATIONS ##
        #########################################
        */
        float mutationChance = 0.005;
        float scoreTotal = 0;
        for(int p=0; p<mScores.size(); p++){
            scoreTotal += mScores.get(p);
        }
        for(int i=0; i<net.size(); i++){
            for(int j=0; j<net.get(i).size(); j++){
                //---------
                float newBias = 0;
                for(int p=0; p<mNets.size(); p++){
                    newBias += mNets.get(p).net.get(i).get(j).bias*mScores.get(p);
                }
                newBias /= scoreTotal;
                net.get(i).get(j).bias = newBias;
                //---------
                for(int z=0; z<net.get(i).get(j).weights.size(); z++){
                    //-------------------
                    float newWeight = 0;
                    for(int p=0; p<mNets.size(); p++){
                        newWeight += mNets.get(p).net.get(i).get(j).weights.get(z)*mScores.get(p);
                    }
                    newWeight /= scoreTotal;
                    net.get(i).get(j).weights.remove(z);
                    net.get(i).get(j).weights.add(z, newWeight);
                    //-------------------
                }
            }
        }
        if(isMutating(mutationChance)){
            //println("MUTATED");
            for(int i=1; i<net.size()-1; i++){
                int rVal1 = floor( random(0, net.get(i-1).size()) );
                int rVal2 = floor( random(0, net.get(i  ).size()) );
                //
                float newWeight = -1.0*net.get(i).get(rVal1).weights.get(rVal2);
                net.get(i).get(rVal1).weights.remove(rVal2);
                net.get(i).get(rVal1).weights.add(rVal2, newWeight);
                //
                net.get(i).get(rVal1).bias *= -1.0;
            }
        }
    }
    boolean isMutating(float mVal){
        float rVal = random(0,1.0);
        if(rVal < mVal){
            //println("MUTATED");
            return true;}
        else{
            return false;}
    }
    int runNetwork(lizard lEntity, fruit nextFruit){
        /*
        Returns action to be performed
        0. Enter input values
        1. Find final weights
        2. Find probability of each final weight
        3. Choose and return action needed

        Inputs here;
        0:lizardPosX
        1:lizardPosY
        //2:lizardDirX
        //3:lizardDirY
        //4:lizardPosFruitX
        //5:lizardPosFruitY
        6:lizardSpd
        */

        //0
        net.get(0).get(0).weightedSum = lEntity.body.get(0).pos.x;
        net.get(0).get(1).weightedSum = lEntity.body.get(0).pos.y;
        //net.get(0).get(2).weightedSum = lEntity.dir.x;
        //net.get(0).get(3).weightedSum = lEntity.dir.y;
        //net.get(0).get(4).weightedSum = nextFruit.pos.x;
        //net.get(0).get(5).weightedSum = nextFruit.pos.y;
        net.get(0).get(2).weightedSum = vecMag(lEntity.body.get(0).vel);

        //1
        //Go through each layer of the network
        for(int i=1; i<net.size(); i++)
        {
            //Go through each node of that layer
            for(int j=1; j<net.get(i).size(); j++)
            {
                net.get(i).get(j).weightedSum = 0;
                for(int p=0; p<net.get(i-1).size(); p++){
                    net.get(i).get(j).weightedSum += net.get(i-1).get(p).weightedSum *net.get(i-1).get(p).weights.get(j);
                    net.get(i).get(j).weightedSum += net.get(i-1).get(p).bias;
                }
                net.get(i).get(j).weightedSum = (float)Math.tanh( net.get(i).get(j).weightedSum );
            }
        }

        //#########################
        //## CONSIDER -VE VALUES ##
        //#########################
        //2
        //Find total weight for final nodes
        float totalWeight = 0;
        for(int i=0; i<net.get( net.size()-1 ).size(); i++){
            totalWeight += net.get( net.size()-1 ).get(i).weightedSum;
        }
        //Form lists for probabilities
        ArrayList<Float> actionProbs = new ArrayList<Float>();
        ArrayList<Integer> actionNum = new ArrayList<Integer>();
        for(int i=0; i<net.get( net.size()-1 ).size(); i++){
            actionProbs.add( net.get( net.size()-1 ).get(i).weightedSum / totalWeight );
            actionNum.add( i );
        }
        //Sort it
        for(int i=0; i<actionProbs.size(); i++){
            boolean switched = false;
            for(int j=0; j<actionProbs.size()-1; j++){
                if(actionProbs.get(j) < actionProbs.get(j+1)){
                    float valueProb = actionProbs.get(j+1);
                    int valueNum    = actionNum.get(j+1);
                    actionProbs.remove(j+1);
                    actionNum.remove(j+1);
                    actionProbs.add(j, valueProb);
                    actionNum.add(j, valueNum);

                    switched = true;
                }
            }
            if(!switched){
                break;
            }
        }

        //3
        int action = 0;
        float rVal = random(0,0.6);
        for(int i=0; i<actionProbs.size(); i++){
            rVal -= actionProbs.get(i);
            if(rVal <= 0){
                action = actionNum.get(i);
                break;
            }
        }
        return action;
    }
}

class node{
    ArrayList<Float> weights = new ArrayList<Float>();
    float bias;
    float weightedSum = 0;

    node(){
        //pass
    }

    //pass
}