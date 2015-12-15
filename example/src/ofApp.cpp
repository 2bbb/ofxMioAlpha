#include "ofApp.h"



//--------------------------------------------------------------
void ofApp::setup(){
    ble.setup();
    
    // Replace your Mio UUID.
    // UUID is printed to log window when we found Mio device.
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    
    //    uuids.push_back("EB9E30A5-7FE2-4FED-97A8-8EB2DCEF0AB3"); // ake mio alpha
//    uuids.push_back("A1CAD737-2144-4A8B-8A4B-05E4BF93E871"); // CC2650 SensorTag v2.0
//    uuids.push_back("C80EC239-EDDE-4DC8-95DC-02AD0B221B81"); // CC2650 SensorTag v2.0
    uuids.push_back("2FA9F3D7-39C6-446B-88FB-C6CDC4612EB5"); // SensorTag v1.0
    uuids.push_back("0F1D1580-2439-405A-BDF5-AB6B98B79851"); // SensorTag v1.0
    for(int i = 0; i < uuids.size(); i++) {
        ble.addDeviceUUID(uuids[i]);
    }
    
    bStartScan = ble.startScan();
    nTag = uuids.size();
    history.resize(nTag);

    timeLastBeated = 0.0;
    timeLastScanned = 0.0;

    //
}

//--------------------------------------------------------------
void ofApp::update(){
    // If ble succeeds in start to scan device, startScan will return true.
    if(!bStartScan) {
        bStartScan = ble.startScan();
    }
    
    for(int i=0; i< nTag; i++ ){
        if(ble.isConnectedToDevice(uuids[i])) {
            timeLastScanned = ofGetElapsedTimef();
            vector<int> hbs = ble.getLatestHeartBeatsFromDevice(uuids[i]);
            if(hbs.size()) {
                ofLogNotice() << "from " << uuids[i];
                for(auto hb : hbs) {
                    ofLogNotice() << "IR temperture " << hb;
                    history[i].setCurrent(hb);
                }
            }else{
                //            lux = 0.0;
                //            timeLastBeated = 0.0;
        }
    }
    }
 }

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackground(0);
    // Paints screen sensed max brightness as white.
    
    for (int i=0; i<nTag; i++) {
        int history_size =  history[i].value_history.size();

        for(int j = 0; j < ofGetHeight(); j++){
            if( j >= history_size ){
                break;
            }
            ofSetColor( ofMap(history[i].value_history[j],
                              history[i].min, history[i].max + 0.1, 0, 255) );
            ofRect((ofGetHeight()/nTag)*i, j, ofGetWidth()/nTag, 1);
            /*
             int start_index = history[i].value_history.size() - ofGetHeight();
            if(start_index < 0 ){
                start_index = 0;
            }
            int line_index = start_index + j;
            if(line_index >= history[i].value_history.size() ){
                break;
            }
*/
            //            ofSetColor( ofMap(history[i].value_history[line_index],
//                              history[i].min, history[i].max+0.1, 0, 255) );


        }
    }
    

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
