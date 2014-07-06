
$fn = 60;

use <lib/PneumaticConnectorCust.scad>
use <lib/Thread_Library.scad>
use <tip.scad>

TUBE_DIAMETER = 4;
TUBE_CLEARANCE = 0.9;
TUBE_CLEARANCE_JAM = 0.32;

HEIGHT = 14;

TUBE_DIAMETER = 4.0;
TUBE_THICKNESS = 0.6;

module thread(pitch_radius) {
    trapezoidThread(
        length=8, 				// axial length of the threaded rod
        pitch=1.2,				 // axial distance from crest to crest
        pitchRadius=pitch_radius, 			// radial distance from center to mid-profile
        threadHeightToPitch=0.4, 	// ratio between the height of the profile and the pitch
                            // std value for Acme or metric lead screw is 0.5
        profileRatio=0.4,			 // ratio between the lengths of the raised part of the profile and the pitch
                            // std value for Acme or metric lead screw is 0.5
        threadAngle=30, 			// angle between the two faces of the thread
                            // std value for Acme is 29 or for metric lead screw is 30
        RH=true, 				// true/false the thread winds clockwise looking along shaft, i.e.follows the Right Hand Rule
        clearance=0.1, 			// radial clearance, normalized to thread height
        backlash=0.1, 			// axial clearance, normalized to pitch
        stepsPerTurn=24 			// number of slices to create per turn
    );
}

module tube_link(tube_diameter = TUBE_DIAMETER, tube_thickness = TUBE_THICKNESS, height = HEIGHT) {
    difference() {
        cylinder(r = tube_diameter / 2, h = height);
        cylinder(r = tube_diameter / 2 - tube_thickness, h = height * 2);
    }

    for (pos = [
        [ 0, 0, height - 4 ],
        [ 0, 0, height - 10 ],
    ]) {
        translate(pos) {
            barb_nub(tube_diameter - .5);
        }
    }
}

module connector(   pitch_radius = 4.5,
                    thread_height = 7,
                    tube_diameter = TUBE_DIAMETER,
                    tube_thickness = TUBE_THICKNESS,
                    nut_height = 7,
                    with_link = true,
                    link_90 = false,
                    thread = true) {

    module pos_90() {
        rotate([0, 90, 30]) {
            translate([- thread_height - nut_height / 2 - 0.5, 0, 0]) {
                if ($children) {
                    for (i = [0 : $children - 1]) {
                        children(i);
                    }
                }
            }
        }
    }

    difference() {
        union() {
            if (thread) {
                thread(pitch_radius);
            }

            translate([0, 0, thread_height - .1]) {
                cylinder(r = pitch_radius * 1.1, h = nut_height, $fn = 6);
            }

            if (with_link) {
                if (link_90) {
                    translate([3, 1.7, 0]) {
                        pos_90() {
                            tube_link();
                        }
                    }
                } else {
                    translate([0, 0, thread_height + nut_height - .2]) {
                        tube_link();
                    }
                }
            }
        }

        translate([0, 0, -1]) {
            cylinder(r1 = pitch_radius / 1.3, r2 = tube_diameter / 2 - tube_thickness / 2, h = thread_height);

            if (link_90) {
                cylinder(r = tube_diameter / 2 - tube_thickness / 2, h = thread_height + nut_height - 1);
                translate([0, 0, 1]) {
                    pos_90() {
                        cylinder(r = tube_diameter / 2 - tube_thickness, h = 100);
                    }
                }
            } else {
                cylinder(r = tube_diameter / 2 - tube_thickness / 2, h = 100);
            }
        }
    }
}

module tube_pivot() {
    height = 5;

    module cyl(height, thickness, full = false) {
        difference() {
            cylinder(r = (TUBE_DIAMETER + thickness) / 2, h = height);
            if (!full) {
                cylinder(r = (TUBE_DIAMETER + TUBE_CLEARANCE_JAM) / 2, h = height * 4, center = true);
            }
        }
    }

    translate([0, 0, 1]) {
        cyl(height - 1, 2);
    }

    translate([0, 0, 5]) {
        cyl(height, 4);
    }

    translate([0, 0, 0]) {
        difference() {
            cyl(height, 4, full = true);
            translate([0, 0, -1]) {
                cyl(height * 2, 2.3, full = true);
            }
        }
    }

    //connector(link_90 = true, thread = false);
}

module tube_adaptator(  tube_diameter = 4,
                        tube_clearance = 0.3,
                        tube_thickness = 1,
                        height = 14) {

    connector(link_90 = true, thread = false, thread_height = 0);

    translate([0, 0, -height / 2]) {
        difference() {
            cylinder(r = tube_diameter / 2 + tube_thickness * 2, h = height, center = true);
            cylinder(r = (TUBE_DIAMETER + tube_clearance) / 2, h = 100, center = true);
        }
    }
}

union() {
    tube();

    tube_pivot();
}

connector(link_90 = true);
connector(with_link = false);
connector();

!tube_adaptator();

