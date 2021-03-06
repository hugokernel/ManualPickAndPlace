
use <table.scad>
use <common.scad>

$fn = 40;

BEARING_INTERNAL_DIAMETER = 7.8;
BEARING_EXTERNAL_DIAMETER = 22.05;
BEARING_INTERNAL_ROTATE_DIAMETER = 12;
BEARING_HEIGHT = 7;

BEARING_FLANGE_DIAMETER = 25.06;
BEARING_FLANGE_THICKNESS = 1.54;

THICKNESS = 5;

ARM_THICKNESS = 3;

DEMO = false;

module tube(external, internal, height) {
    difference() {
        cylinder(r = external / 2, height, center = true);
        cylinder(r = internal / 2, height * 2, center = true);
    }
}

module bearing( external_diameter = BEARING_EXTERNAL_DIAMETER,
                internal_diameter = BEARING_INTERNAL_DIAMETER,
                height = BEARING_HEIGHT,
                flange_diameter = 0,
                flange_thickness = 0
                ) {

    tube(external_diameter, internal_diameter, height);

    if (flange_thickness) {
        translate([0, 0, height / 2 - flange_thickness / 2]) {
            tube(flange_diameter, external_diameter - 1, flange_thickness);
        }
    }
}

module bearing_flange() {
    bearing(flange_diameter=BEARING_FLANGE_DIAMETER, flange_thickness=BEARING_FLANGE_THICKNESS);
}

/*
module bearing() {
    difference() {
        cylinder(r = BEARING_EXTERNAL_DIAMETER / 2, BEARING_HEIGHT, center = true);
        cylinder(r = BEARING_INTERNAL_DIAMETER / 2, BEARING_HEIGHT * 2, center = true);
    }
}
*/

module m3_nut(height = 2) {
    cylinder(r = 3.4, h = height, center = true, $fn = 6);
}

module m3_hole(length = 50) {
    cylinder(r = 1.9, h = length, center = true);
}

module m3_cone(height = 2) {
    cylinder(r1 = 3.9, r2 = 1.9, h = height, center = true);
}

module arm_male(width = 15,
                length = 40,
                thickness = ARM_THICKNESS,
                holder_height = BEARING_HEIGHT / 2,
                nut = true,
                cone = false,
                bearing_support_thickness = 0.5,
                slot = true) {

    bearing_support_diameter = 12;

    clear = -0.15;

    module bearing() {
        translate([0, 0, bearing_support_thickness / 2]) {
            cylinder(r = bearing_support_diameter / 2, h = bearing_support_thickness, center = true);

            translate([0, 0, thickness / 2 + holder_height / 2 - bearing_support_thickness]) {
                cylinder(r = BEARING_INTERNAL_DIAMETER / 2 - clear, h = holder_height, center = true);
            }
        }
    }

    module position() {
        for (pos = [
            [ -length / 2, 0, 0 ],
            [ length / 2, 0, 0 ]
        ]) {
            translate(pos) {
                for (i = [0 : $children - 1]) {
                    children(i);
                }
            }
        }
    }

    translate([length / 2, 0, 0]) {
        difference() {
            union() {
                position() {
                    cylinder(r = width / 2, h = thickness, center = true);
                    translate([0, 0, thickness / 2]) {
                        bearing();
                    }
                }

                cube(size = [length, 15, thickness], center = true);

                // Slot
                if (slot) {
                    for (pos = [
                        [0, 5, thickness / 2],
                        [0, 0, thickness / 2],
                        [0, -5, thickness / 2]
                    ]) {
                        translate(pos) {
                            cube(size = [length, 3, 1], center = true);
                        }
                    }
                }
            }

            translate([0, 0, -thickness / 5.5]) {
                position() {
                    if (nut) {
                        m3_nut();
                    } else if (cone) {
                        m3_cone();
                    }

                    m3_hole();
                }
            }
        }
    }
}

closed_cap_thickness = 2.5;
module female_bearing(  width = 30,
                        thickness = THICKNESS,
                        clear = 0.15,
                        closed = false,
                        closed_cap_thickness = closed_cap_thickness,
                        fn = $fn) {
    difference() {
        cylinder(r = width / 2, h = thickness, center = true, $fn = fn);
        cylinder(r = BEARING_EXTERNAL_DIAMETER / 2 + clear, thickness + 1, center = true);
    }

    if (closed) {
        translate([0, 0, -thickness / 2 - closed_cap_thickness / 2]) {
            difference() {
                cylinder(r = width / 2, h = closed_cap_thickness, center = true);
                translate([0, 0, 1]) {
                    cylinder(r = BEARING_INTERNAL_ROTATE_DIAMETER / 2 + 2, h = 10, center = true);
                }
            }
        }
    }

    if ($children) {
        for (i = [0 : $children - 1]) {
            children(i);
        }
    }

    if (DEMO) {
        color("GREY") {
            bearing();
        }
    }
}

module female_bearing_flange(   width = 30,
                                thickness = BEARING_HEIGHT,
                                clear = 0.15,
                                fn = $fn) {
    difference() {
        cylinder(r = width / 2, h = thickness, center = true, $fn = fn);
        bearing(    height=BEARING_HEIGHT + 0.1,
                    flange_diameter = BEARING_FLANGE_DIAMETER + clear,
                    internal_diameter=0,
                    flange_thickness = BEARING_FLANGE_THICKNESS,
                    external_diameter=BEARING_EXTERNAL_DIAMETER + clear);
    }

    if (DEMO) {
        color("GREY") {
            bearing_flange();
        }
    }
}

module arm_female(gap = 40, thickness = 5, closed = false) {

    width = 30;

    clear = 0.2;

    for (data = [
        [ -gap / 2, 0 ],
        [ gap / 2, 1 ]
    ]) {
        translate([ data[0], 0, 0 ]) {
            female_bearing(width = width, thickness = thickness, clear = clear, closed = closed) {
                if ($children) {
                    children(data[1]);
                }
            }
        }
    }

    if (closed) {
        translate([0, 0, -closed_cap_thickness / 2]) {
            cube(size = [gap - BEARING_EXTERNAL_DIAMETER - clear * 2, 15, thickness + closed_cap_thickness], center = true);
        }
    } else {
        cube(size = [gap - BEARING_EXTERNAL_DIAMETER - clear * 2, 15, thickness], center = true);
    }
}

HOLDER_DIAMETER = 28;
module holder_male(height = 14, block_size = 3, skirt_thickness = 2, skirt_size = 2, full = false) {

    module hole() {
        translate([-HOLDER_DIAMETER / 2, 0, 0]) {
            rotate([0, 90, 0]) {
                cylinder(r = 1, h = HOLDER_DIAMETER, center = true);
            }
        }
    }

    module holes() {
        for (rot = [0 : 90 : 360]) {
            rotate(rot) {
                hole();
            }
        }
    }

    difference() {
        union() {
            cylinder(r = HOLDER_DIAMETER / 2, h = height, center = true);

            if (!full) {
                translate([0, 0, -height / 2 + skirt_thickness / 2]) {
                    cylinder(r = HOLDER_DIAMETER / 2 + skirt_size / 2, h = skirt_thickness, center = true);
                }
            }
        }
        if (!full) {
            cylinder(r = (HOLDER_DIAMETER - 2) / 2, h = height + 1, center = true);
            holes();
        }
    }

    translate([HOLDER_DIAMETER / 2 + block_size / 2 - 1, 0, 0]) {
        cube(size = [block_size, block_size, height], center = true);
    }

    if (full) {
        holes();
    }
}

module holder(thickness = 18) {

    width = 32;

    clear = 1.02;

    rotate([0, 180, 0]) {
        arm_female(closed = true, thickness = BEARING_HEIGHT);
    }

    translate([0, 0, 24]) {
        difference() {
            hull() {
                rotate([0, 90, 0]) {
                    cylinder(r = HOLDER_DIAMETER / 2 + 6, h = thickness, center = true);//, $fn = 10);
                }

                translate([0, 0, -16]) {
                    cube(size = [thickness, 15, 6], center = true);
                }
            }

            rotate([0, 90, 0]) {
                scale([clear, clear, clear]) {
                    holder_male(height = thickness, full = true);
                }
            }
        }
    }
}

module mount_point() {
    thickness = 7;
    union() {
        translate([thickness / 2 - 3, 0, 0]) {
            socket(female = false, thickness = 8, height = 35, oblong = true, hole_diameter = 4.5);
        }

        translate([0, 17, 3]) {
            rotate([0, 0, 90]) {
                linear_extrude(height = BEARING_HEIGHT) {
                    polygon([[3,2],[18,2],[18,5],[14,10],[12.5,23]]);
                }
            }
        }

        translate([-2.5, 26, -4]) {
            rotate([-90,-180, 0]) {
                linear_extrude(height = thickness) {
                    polygon([[0,0],[0,7],[9, 7]]);
                }
            }
        }

        translate([-2.5, 29.5, 0]) {
            rotate([-90, 180, -90]) {
                linear_extrude(height = thickness) {
                    polygon([[-10, 10],[-10,-15],[16,5],[16,10]]);
                }
            }
        }
    }

    translate([-5, 62.3, BEARING_HEIGHT / 2 - 0.5]) {
        spirit_level_support(height=BEARING_HEIGHT);
    }

    //translate([-15, 42, 6.5]) {
        //female_bearing(thickness = BEARING_HEIGHT, closed = true, closed_cap_thickness = 0.5);
    translate([-17, 43, 6.5]) {
        female_bearing_flange(thickness = BEARING_HEIGHT, width=35, clear = 0.35);
    }
}

module arm_blocker() {
    gap = 40;

    arm_male(length = gap, holder_height = BEARING_HEIGHT / 2);

    %translate([gap, 0, THICKNESS]) {
        female_bearing();
    }

    translate([gap, 0, 0]) {
        translate([0, 13, 0]) {
            cube(size = [7, 19, ARM_THICKNESS], center = true);
        }

        translate([0, 20, 5]) {
            cube(size = [3, 5, 7], center = true);
        }
    }
}

module tripod(blocker = false) {
    gap = 40;
    thickness = BEARING_HEIGHT;

    %rotate([0, 0, -90]) {
        translate([-gap, gap / 2, -21.5]) {
            arm_blocker();
        }
    }

    /*
    rotate([0, 90, 0]) {
        translate([12, -19, -BEARING_HEIGHT / 2]) {
            spirit_level_support(height=BEARING_HEIGHT);
        }
    }
    */

    clear = 0.2;

    translate([0, 0, -16]) {
        rotate([180, 0, 0]) {
            //difference() {
                arm_female(thickness = thickness, closed = true);
                //cube(size= [ 5, 5, 20 ], center = true);
            //}
        }

        translate([0, 0, 19]) {
            rotate([0, 90, 0]) {
                female_bearing_flange(width = 38, thickness = thickness, clear = clear, fn = $fn);
            }
        }
    }

    //arm_female_special(thickness = thickness, closed = true, width = 38);//, fn = 10);

    if (blocker) {
        translate([gap / 2, 0, -14.75]) {
            difference() {
                cylinder(r = 17, h = thickness + closed_cap_thickness, center = true);
                cylinder(r = 13, h = thickness + 3, center = true);
                for (rot = [ -90 : 15 : 90 ]) {
                    rotate([rot, 90, 0]) {
                        cylinder(r = 0.75, h = 20, $fn = 40);
                    }
                }
            }
        }
    }
}

module holder_male_bearing() {
    rotate([0, 180, 0]) {
        holder_male(height = 20);
    }

    for (data = [
        [[0, 0, 5], 0],
        [[0, 0, 5], 1]
    ]) {
        mirror([0, 0, data[1]]) {
            translate(data[0]) {
                female_bearing(width = HOLDER_DIAMETER - 1, thickness = 10, closed = true, closed_cap_thickness = 2);
            }
        }
    }

    %for (pos = [
        [0, 0, 6],
        [0, 0, -6]
    ]) {
        translate(pos) {
            bearing();
        }
    }
}

module holder_male_syringe() {
    rotate([0, 180, 0]) {
        holder_male(height = 20);
    }

    %cylinder(r = 25 / 2, h = 115, center = true);
}

module demo() {

    final_horizontal_angle = 0;
    vertical_angle = 0;
    arm_length = 50;

    module dbl_arm_male(width = 15, length = 40, thickness = 3) {
        //arm_male(width, length, thickness);
        arm_link();
        translate([0, 0, 12.6]) {
            rotate([ 180, 0, 0]) {
                arm_link();
                //arm_male(width, length, thickness);
            }
        }
    }

    module arms(angle = 0) {
        //rotate([90, angle, -270]) {
        rotate([0, 0, angle]) {
            arm_male();
        }

        translate([0, 39.5, 0]) {
            rotate([0, 0, angle]) {
                arm_blocker();
            }
        }
    }

    //$t = 0;

    module mobile(angle = 0) {

        // Very uggly !
        offset_z = angle * 0.6;

        translate([47 - arm_length, 0.5, 5]) {
            rotate([0, -90, -180 + final_horizontal_angle]) {
                //arm_blocker();
                tripod(blocker = true);
            }
        }

        translate([25.5 - arm_length, -39.5, -14.5 - offset_z]) {
            rotate([90, 0, 90]) {
                arms(angle);
            }
        }

        translate([31 - arm_length, -39.5, 5.5 - offset_z]) {
            rotate([0, 90, 0]) {
                holder();
            }
        }

        translate([55 - arm_length, -39.5, 8 - offset_z]) {
            holder_male_bearing();
        }
    }

    mount_point();

    translate([-17, 42, 0.75]) {
        rotate([0, 0, 180 - 0]) {
            dbl_arm_male(length = arm_length);
        }
    }

    translate([-68.5, 42, -0.25]) {
        rotate([0, 0, $t * 20]) {
            mobile(angle = $t * 20);
        }
    }
}

module arm_link(width = 15, length = 50, thickness = 3, holder_height = BEARING_HEIGHT / 2 + 0.75, male = true, nut = true, cone = false) {
    bearing_support_thickness = 1.5;
    /*
        arm_male(width = 15,
                length = 40,
                thickness = ARM_THICKNESS,
                holder_height = BEARING_HEIGHT / 2,
                nut = true,
                cone = false) {
     */
    arm_male(width = 15, length = length, thickness = thickness, holder_height = holder_height, bearing_support_thickness = bearing_support_thickness, nut = nut, cone = cone);

    module pos() {
        translate([length / 2, 0, thickness / 2 + holder_height / 2]) {
            if ($children) {
                for (i = [0 : $children - 1]) {
                    children(i);
                }
            }
        }
    }

    module block(height = 3) {
        hull() {
            for (pos = [
                [0, -4, holder_height / 2 + bearing_support_thickness],
                [0, 4, holder_height / 2 + bearing_support_thickness]
            ]) {
                translate(pos) {
                    cylinder(r = 2, h = height, center = true);
                }
            }
        }
    }

    coeff = 1.07;
    pos() {
        difference() {
            cube(size = [8, width, holder_height + bearing_support_thickness], center = true);
            if (!male) {
                scale([coeff, coeff, coeff]) {
                    translate([0, 0, -2.5]) {
                        block(height = 5);
                    }
                }
            }
        }
    }

    if (male) {
        pos() {
            block();
        }
    }

    if (male)
    %translate([0, 0, 6.5]) {
        bearing(flange_diameter = BEARING_FLANGE_DIAMETER, flange_thickness = BEARING_FLANGE_THICKNESS);
    }
}

/*
module led_support() {
    width = 15;

    linear_extrude(height = 2) {
        difference() {
            hull() {
                for (pos = [ -12.5, 12.5 ]) {
                    translate([0, pos, 0]) {
                        circle(r = width / 2);
                    }
                }
            }

             for (pos = [ -12.5, 12.5 ]) {
                translate([0, pos, 0]) {
                    circle(r = 1);
                }
             }

            circle(r = 3);
        }

        width2 = 7;
        difference() {
            union() {
                translate([width / 2, -width2 / 2, 0]) {
                    square([30, width2]);
                }

                translate([30 + width / 2, 0, 0]) {
                    circle(r = 5);
                }
            }

            translate([30 + width / 2, 0, 0]) {
                circle(r = 3 / 2);
            }
        }
    }
}
*/

module led_support() {

    height = 7;

    module half_moon(external_diameter, internal_diameter, height) {
        difference() {
            cylinder(r = external_diameter / 2, h = height, center = true);
            cylinder(r = internal_diameter / 2, h = height * 2, center = true);
            translate([external_diameter / 2, 0, 0]) {
                cube(size = [external_diameter, external_diameter, height * 2], center = true);
            }

            translate([-external_diameter / 2 + 1, -external_diameter / 2, 0]) {
                cube(size = [external_diameter, external_diameter, height * 2], center = true);
            }
        }
    }

    module half_moon_led() {
        difference() {
            union() {
                half_moon(external_diameter=36, internal_diameter=32, height=6);
                translate([0, 0, 2.5]) {
                    half_moon(external_diameter=40, internal_diameter=30, height=height);
                }

                translate([-15, 0, -1]) {
                    rotate([0, 0, 45]) {
                        cube(size = [22, 6, height]);
                    }
                }
            }

            translate([2, 12, -4]) {
                rotate([0, 0, 45]) {
                    cube(size = [10, height * 2, height * 2]);
                }
            }

            translate([-4.7, 15.0, 2.5]) {
                rotate([0, -90, 45]) {
                    scale([1.1, 1.1, 1.1]) {
                        led();
                    }
                }
            }
        }

        for (rot = [ 25, 70 ]) {
            rotate([ 0, 0, rot ]) {
                translate([ 0, 17, -4.5 ]) {
                    cylinder(r = 0.7, h = 3);
                }
            }
        }
    }

    half_moon_led();
    mirror([0, 1, 0]) {
        half_moon_led();
    }
}

led_support();

!demo();

module paf() {
    arm_link(nut = false, cone = true);
    translate([0, 0, 13]) {
        rotate([180, 0, 0]) {
            arm_link(male = false, nut = false, cone = true);
        }
    }
}

paf();

arm_link(nut = false, cone = true);
arm_link(male = false);

mount_point();

arm_male(length=40, nut=true);
arm_male(length=40, nut=false, cone=true);

arm_male(length=0, nut=false, cone=true);
arm_male(length=0, nut=true, cone=false);

rotate([0, -90, 0]) {
    tripod(blocker = true);
}

union() {
    female_bearing_flange(width = 35, clear = 0.35, fn = fn);
    //%bearing_flange();
}

arm_blocker();

module demo_hold() {
    holder();
    translate([0.5, 0, 24]) {
        rotate([0, 90, 0]) {
            //holder_male();
            holder_male_bearing();
        }
    }
}

holder();
demo_hold();
holder_male();

holder_male_bearing();
holder_male_syringe();

