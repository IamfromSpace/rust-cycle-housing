module housing(
  thickness, // general thickness of walls
  pi_rod_radius, // radius of the screw holes on the pi
  pi_rod_height, // height of the rods to pass through the pi, button shim, and the adapter
  pi_rod_spacing_x, // distance from the screw hole centers of the pi along the x axis
  pi_rod_spacing_y, // distance from the screw hole centers of the pi along the y axis
  pi_rod_clearance, // distance from the pi screw hole centers to the edge of the board
  pi_solder_clearance, // height of the solder joints on the underside of the pi
) {
  cube([pi_rod_spacing_x + 2*(pi_rod_radius + pi_rod_clearance + thickness), pi_rod_spacing_y + 2*(pi_rod_radius + pi_rod_clearance + thickness), thickness]);
  translate([pi_rod_radius + pi_rod_clearance + thickness, pi_rod_radius + pi_rod_clearance + thickness, thickness])
    for (x = [0, 1])
      for (y = [0, 1])
        translate([x*pi_rod_spacing_x, y*pi_rod_spacing_y, 0]) {
          cylinder(pi_rod_height + pi_solder_clearance, pi_rod_radius - $tolerance/2, pi_rod_radius - $tolerance/2);
          cylinder(pi_solder_clearance, pi_rod_clearance, pi_rod_clearance);
        }
}

housing(
  3,
  1.5,
  18,
  60,
  30,
  3,
  1.25,
  $fn=60,
  $tolerance = 0.7
);
