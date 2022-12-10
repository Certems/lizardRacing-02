ArrayList<Integer> stdNetwork           = new ArrayList<Integer>();
ArrayList<ArrayList<fruit>> sys2Fruits  = new ArrayList<ArrayList<fruit>>();
ArrayList<lizard> lizards               = new ArrayList<lizard>();
ArrayList<PVector> fruitPosSets         = new ArrayList<PVector>();
int lizardNumber = 150;

int wantedRound = 3;
int roundNumber = 0;
float roundTime = 0.0;
float timeMax   = 25.0*60.0;
int frameSkip   = 20;

int standardSize     = 6;        //Adjust these **
float standardLength = 10.0;     //
int fruitNumber      = 8;
float fruitDetectRad = 250.0;
float eOffset        = 200.0;

boolean lowPolyMode = false;

ArrayList<Float> roundScores = new ArrayList<Float>();
boolean showGraph       = false;
boolean showScoreSpace  = true;