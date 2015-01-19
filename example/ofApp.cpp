#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    mio.setup();
    
    // Replace your Mio UUID.
    // UUID is printed to log window when we found Mio device.
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    uuids.push_back("BB6BCED9-2EE5-4DD2-9CCD-529D5E9CC0E5");
    uuids.push_back("89CF3564-E897-47DF-A0F1-18ACB8D67BE8");
    for(int i = 0; i < uuids.size(); i++) {
        mio.addDeviceUUID(uuids[i]);
    }
    
    bStartScan = mio.startScan();
    c = 0.0f;
}

//--------------------------------------------------------------
void ofApp::update(){
    // If mio succeeds in start to scan device, startScan will return true.
    if(!bStartScan) {
        bStartScan = mio.startScan();
    }
    
    for(int i = 0; i < uuids.size(); i++) {
        if(mio.isConnectedToDevice(uuids[i])) {
            vector<int> hbs = mio.getLatestHeartBeatsFromDevice(uuids[i]);
            if(hbs.size()) {
                ofLogNotice() << "from " << uuids[i];
                for(auto hb : hbs) {
                    ofLogNotice() << "heart rate " << hb;
                }
                c = 255.0f;
            }
        } else {
            
        }
    }
    
    c = ofLerp(c, 0, 0.1f);
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackground((unsigned char)(c), 0, 0);
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){
    
}
