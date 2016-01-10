
SPIRIT_LEVEL_DIAMETER = 9.97;
SPIRIT_LEVEL_HEIGHT = 6.3;

module spirit_level(diameter=SPIRIT_LEVEL_DIAMETER, height=SPIRIT_LEVEL_HEIGHT) {
    cylinder(r = diameter / 2, h = height);
}

module spirit_level_support(wall_thickness=2, base_thickness=1, clear=0.3, height=SPIRIT_LEVEL_HEIGHT + 1) {
    difference() {
        cylinder(r = SPIRIT_LEVEL_DIAMETER / 2 + wall_thickness, h = height);
        translate([0, 0, 1]) {
            spirit_level(diameter=SPIRIT_LEVEL_DIAMETER + clear, height=SPIRIT_LEVEL_HEIGHT + base_thickness);
        }

        translate([0, 0, -1]) {
            cylinder(r = SPIRIT_LEVEL_DIAMETER / 4, h = 5);
        }
    }
}

LED_DIAMETER = 5;
LED_HEIGHT = 8.7;
LED_SKIRT_DIAMETER = 5.85;
LED_SKIRT_HEIGHT = 1.3;

module led() {
    body_height = LED_HEIGHT - LED_DIAMETER / 2;
    cylinder(r = LED_DIAMETER / 2, h = body_height, center = true);
    translate([0, 0, LED_HEIGHT / 2 - LED_DIAMETER / 4]) {
        sphere(r = LED_DIAMETER / 2);
    }

    translate([0, 0, - body_height / 2]) {
        cylinder(r = LED_SKIRT_DIAMETER / 2, h = LED_SKIRT_HEIGHT);
    }
}

