
use <arms.scad>
use <table.scad>

socket_width = 40;
module demo() {
    dolly_ys();

    translate([-58.5, 0, 10]) {
        mount_point();

        %translate([-4, 0, 0]) {
            socket_small_ring(support = true);
            socket_small_ring(support = false);
        }
    }
}

demo();

