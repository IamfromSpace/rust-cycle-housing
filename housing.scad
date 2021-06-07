module housing(
  thickness, // general thickness of walls
  pi_rod_radius, // radius of the screw holes on the pi
  pi_rod_height, // height of the rods to pass through the pi, button shim, and the adapter
  pi_rod_spacing_x, // distance from the screw hole centers of the pi along the x axis
  pi_rod_spacing_y, // distance from the screw hole centers of the pi along the y axis
  pi_rod_clearance, // distance from the pi screw hole centers to the edge of the board
  pi_solder_clearance, // height of the solder joints on the underside of the pi
  button_shim_extension, // how much further the button shim sticks out beyond the pi
  button_shim_height, // distance from the bottom of the pi to the bottom of the shim
  button_x, // total width of a button
  button_opening_x, // width of the opening to reveal the button
  button_opening_z, // height of the opening to reveal the button
  button_offset, // distance from button E to its closest side of the board
) {
  inner_y = button_shim_extension + $tolerance/2 + pi_rod_spacing_y + 2*(pi_rod_radius + pi_rod_clearance + thickness);
  inner_x = pi_rod_spacing_x + 2*(pi_rod_radius + pi_rod_clearance + thickness);

  cube([inner_x, inner_y, thickness]);

  translate([pi_rod_radius + pi_rod_clearance + thickness, pi_rod_radius + pi_rod_clearance + thickness, thickness])
    for (x = [0, 1])
      for (y = [0, 1])
        translate([x*pi_rod_spacing_x, y*pi_rod_spacing_y, 0]) {
          cylinder(pi_rod_height + pi_solder_clearance, pi_rod_radius - $tolerance/2, pi_rod_radius - $tolerance/2);
          cylinder(pi_solder_clearance, pi_rod_clearance, pi_rod_clearance);
        }

  translate([0, inner_y, 0])
    difference() {
      cube([inner_x, thickness, pi_solder_clearance + thickness + pi_rod_height /* TODO */]);
      for (i = [0:4]) {
        translate([i * button_x + thickness + button_offset, 0, button_shim_height + pi_solder_clearance + thickness])
          cube([button_opening_x, thickness, button_opening_z]);
      }
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
  4,
  4,
  8,
  6,
  3,
  22,
  $fn=60,
  $tolerance = 0.7
);
