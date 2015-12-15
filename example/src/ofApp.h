#pragma once


#include "ofMain.h"
#include "ofxBleSensorTag.h"

#define HISTORY_MAX 10000

class dataHistory{
public:
    double current, max, min;
    deque<double> value_history;
    void setCurrent(double value){
        current = value;
        if(max < value){
            max = value;
        }
        if(min > value){
            min = value;
        }
        value_history.push_front(value);
        while( value_history.size() > HISTORY_MAX ){
            value_history.pop_back();
        }
    }
};

class ofApp : public ofBaseApp{
public:
    void setup();
    void update();
    void draw();

    void keyPressed(int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);
    void exit() {
        ble.disconnect();
    }
    
private:
    ofxBleSensorTag ble;
    bool bStartScan;

    vector<string> uuids;

    vector<dataHistory> history;
    
    int nTag;
    double lux[16];
    double max_lux[16];
    float timeLastBeated;
    float timeLastScanned;
};
