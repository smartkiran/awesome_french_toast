//
//  ThralledGlobals.h
//  Thralled
//
//  Created by sai on 8/18/12.
//
//

#ifndef Thralled_ThralledGlobals_h
#define Thralled_ThralledGlobals_h

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define DRAG_MIN 400 //this is square of minimum dist.
const float timeStep = 1.0f / 60.0f;
const int velocityIterations = 10;
const int positionIterations = 4;
const float maxWalkSpeed=4.0f;
const float maxJumpInPixels=200.0f;
const float maxDoorSpeed=2.0f;
const float maxLeverSpeed=2.0f;
const float maxDoorOpenTime=60.0f;

enum tags{
    TAG_ISAURA=0,
    TAG_DOOR=1,
    TAG_LEVER=2,
    TAG_GROUND=3,
    TAG_RIGHT_SIDEWALL=4,
    TAG_LEFT_SIDEWALL=5,
    TAG_ISAURA_WITH_LEVER=6
};

#endif
