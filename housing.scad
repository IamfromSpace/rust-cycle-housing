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
  display_extension, // how much further the display sticks out beyond the button shim
  display_height, // distance between the bottom of the pi board and the bottom of the display board
  display_guide_radius, // radius of the screw holes on the display board
  display_guide_dist, // distance between the screw holes along the button-side edge
  display_guide_offset_y, // distance between top of the board the screw holes
  display_board_thickness, // thickness of the display board
  battery_length, // length of the battery along the parallel non-wire side
  battery_width, // length of the battery along the side with the wire
  battery_thickness, // smallest dimension of the battery
  battery_guard_ratio, // how much of the available space is consumed by the battery guards
  sd_card_protrusion, // how far out of the board the sd card sits
  gps_board_offset, // how far the center of the GPS board is from the edge of the pi board
  gps_board_width, // how wide the GPS board is against the base of the housing
  gps_board_thickness, // thickness of the GPS board
  gps_usb_width, // how much space should be given to avoid the usb connector
  gps_safe_grip_depth, // how tall the grips can be on the GPS board
  power_cutout, // the width to keep open so the battery housing cavity opens freely
  battery_housing_screw_major_radius, // radius of the screw that connects the battery housing to the main housing, from center to outermost thread
  battery_housing_screw_minor_radius, // radius of the screw that connects the battery housing to the main housing, from center shaft (threads ignored)
  battery_housing_screw_head_radius, // radius of the screw that connects the battery housing to the main housing, from center to the outer most point of the head
  bar_radius, // radius of the bars where the stem is clamped
  bar_clamp_gap, // gap between the top and bottom of the bar clamp
  bar_clamp_screw_major_radius, // radius of the screw that connects the bar clamp, from center to outermost thread
  bar_clamp_screw_minor_radius, // radius of the screw that connects the bar clamp, from center shaft (threads ignored)
  bar_clamp_screw_head_radius, // radius of the screw that connects the bar clamp, from center to the outer most point of the head
  stem_width, // widest part of the stem at the front of the clamp on the bars
  stem_clearance, // how far forward the stem protrudes off the bars
  explode = 20, // (view only) separation between components when rendering
  component = "ALL"  // Which part to render
) {
  pi_offset_y = gps_board_thickness/2 + thickness + gps_board_offset;
  inner_y = pi_offset_y + button_shim_extension + $tolerance + pi_rod_spacing_y + 2*pi_rod_clearance;
  pi_length_x = pi_rod_spacing_x + 2*pi_rod_clearance;
  pi_offset_x = sd_card_protrusion;
  inner_x = sd_card_protrusion + pi_length_x + $tolerance + power_cutout;

  joining_plane_x = max(inner_x, battery_length + $tolerance);
  joining_plane_y = max(inner_y, battery_width + $tolerance);

  module battery_housing_screw_housing(component) {
    screw_housing(
      battery_thickness + $tolerance + thickness,
      0,
      thickness,
      battery_housing_screw_major_radius,
      battery_housing_screw_minor_radius,
      battery_housing_screw_head_radius,
      component,
      align = "HEAD"
    );
  }

  // TODO: This fits tightly on the bar, but it also transmits all the
  // vibrations of the road, which makes the display harder to read.  It may
  // make sense to leave room for a foam that would keep the clamp tight, but
  // act as a dampener.
  module bc(component) {
    bar_clamp(
      1.5*thickness,
      bar_radius,
      bar_clamp_screw_major_radius,
      bar_clamp_screw_minor_radius,
      bar_clamp_screw_head_radius,
      stem_clearance,
      thickness + battery_thickness + $tolerance,
      component = component,
      gap = bar_clamp_gap,
      is_stacked = true
    );
  }

  module bc_pair(component) {
    for (i = [-1,1])
      translate([0, -i * (stem_width + $tolerance)/2, 0])
        mirror([0, (i + 1)/2, 0])
          bc(component);
  }

  translate([-$tolerance/2, -$tolerance/2, -thickness - battery_thickness -$tolerance - explode]) {
    if (component == "BATTERY" || component == "ALL") {
      translate([-thickness, -thickness, -thickness]) {
        cube([joining_plane_x + 2*thickness, joining_plane_y + 2*thickness, thickness]);

        for (i = [0,1])
          translate([(1 - i) * (joining_plane_x + 2 * thickness) + $tolerance/2, joining_plane_y/2 + thickness + $tolerance/2, 0])
            rotate([0, 0, i * 180])
              battery_housing_screw_housing("BOTTOM");
      }

      translate([joining_plane_x/2, -thickness, -thickness])
        rotate([0, 0, -90])
          bc_pair("BOTTOM");

      for (i = [0,1])
        translate([-thickness, i*(joining_plane_y + thickness) - thickness, 0])
          cube([joining_plane_x + 2*thickness, thickness, battery_thickness + $tolerance]);

      for (i = [0,1])
        translate([battery_length * ((i+1) * (1 - battery_guard_ratio)/3 + i * battery_guard_ratio/2) + $tolerance/2, battery_width + $tolerance, 0])
          cube([battery_length * battery_guard_ratio/2, thickness, battery_thickness/2]);

      for (i = [0,1])
        translate([i*(joining_plane_x + thickness) - thickness, -thickness, 0])
          cube([thickness, joining_plane_y + 2*thickness, battery_thickness + $tolerance]);

      for (i = [0,1])
        translate([battery_length + $tolerance, battery_width * ((i+1) * (1 - battery_guard_ratio)/3 + i * battery_guard_ratio/2) + $tolerance/2, 0])
          cube([thickness, battery_width * battery_guard_ratio/2, battery_thickness/2]);
      }

      if (component == "ALL")
        translate([joining_plane_x/2, -thickness, -thickness + 2*explode])
          rotate([0, 0, -90])
            bc_pair("TOP");

      if (component == "BAR_CLAMP_TOP")
        bc("TOP");
    }

  if (component == "MAIN" || component == "ALL") {
    translate([0, 0, -thickness]) {
      difference() {
        translate([-thickness - $tolerance/2, -thickness - $tolerance/2, 0])
          cube([joining_plane_x + 2*thickness, joining_plane_y + 2*thickness, thickness]);
        translate([inner_x - power_cutout, 0, 0])
          cube([power_cutout, inner_y, thickness]);
      }

      for (i = [0,1])
        translate([(1 - i) * (joining_plane_x + 2 * thickness) - thickness, joining_plane_y/2, 0])
          rotate([0, 0, i * 180])
            battery_housing_screw_housing("TOP");
    }

    // TODO: The rods only act as guides, but offer no tension.  The are also
    // short enough that the adapter board tends to ride up and then on top.
    // Either these rods need to be thicker or extended or the top of the
    // housing needs to hold down the boards.
    translate([pi_offset_x + pi_rod_clearance, pi_offset_y + pi_rod_clearance, 0])
      for (x = [0, 1])
        for (y = [0, 1])
          translate([x*pi_rod_spacing_x, y*pi_rod_spacing_y, 0]) {
            cylinder(pi_rod_height + pi_solder_clearance, pi_rod_radius - $tolerance/2, pi_rod_radius - $tolerance/2);
            cylinder(pi_solder_clearance, pi_rod_clearance, pi_rod_clearance);
          }

    // TODO: The buttons are not pressable without some sort of implement (was
    // using a pocket road-side allen key)
    // TODO: The wall seems to be too high, which lifts the board and is
    // potentially causing it to separate off the pins
    // TODO: The wall does not appear to be protruding far enough forward to
    // allow full thickness in front of the display
    // TODO: The button openings are offset too far to the right
    translate([0, inner_y - $tolerance/2, 0])
      button_wall(
        thickness,
        joining_plane_x,
        display_height + pi_solder_clearance,
        button_x,
        button_opening_x,
        button_opening_z,
        pi_offset_x + button_offset,
        button_shim_height + pi_solder_clearance,
        display_extension,
        display_guide_radius,
        display_board_thickness,
        display_guide_dist,
        display_guide_offset_y,
        pi_offset_x + pi_length_x/2
      );

    // TODO: These fit nicely, but the vibrations jostle it out of the grips.
    // They need to be tighter (half tolerance, no tolerance?  Is there a
    // common rule that can be applied for these things?), or there needs to be
    // pressure from the top of the housing.
    translate([pi_offset_x, 0, 0])
      board_grips(thickness, gps_board_thickness, gps_board_width, gps_usb_width, gps_safe_grip_depth);
  }
}

module button_wall(
  thickness, // wall thickness
  length, // how long the wall should be
  height, // height of the wall _excluding_ the display guides
  button_x, // total width of a button
  button_opening_x, // width of the button opening
  button_opening_z, // width of the button opening
  button_offset_x, // offset for the buttons
  button_offset_z, // offset for the buttons
  extension, // how much further the top of the wall should extend
  display_guide_radius, // radius of the screw holes on the display board
  display_guide_thickness, // thickness of the display board
  display_guide_dist, // distance between the screw holes along the button-side edge
  display_guide_offset_y, // distance between top of the board the screw holes
  display_board_center_offset // how far the center of the display board is from the origin
) {
  difference() {
    cube([length, thickness, button_offset_z + button_opening_z]);
    for (i = [0:4]) {
      translate([i * button_x + thickness + button_offset_x, 0, button_offset_z])
        cube([button_opening_x, thickness, button_opening_z]);
    }
  }

  button_shim_bottom_to_display_bottom = height - button_offset_z - button_opening_z;

  translate([0, 0, button_offset_z + button_opening_z])
  rotate([90, 0, 0])
  rotate([0, 90, 0])
  linear_extrude(length)
    polygon(
      [ [0,0]
      , [0, button_shim_bottom_to_display_bottom]
      , [thickness + extension, button_shim_bottom_to_display_bottom]
      , [thickness, 0]
      ]
    );

  // TODO: shallow as possible overhang to support the guides
  translate([0, -display_guide_radius, height])
    difference () {
      for(i = [-1,1])
        translate([display_board_center_offset + i * display_guide_dist/2, extension - display_guide_offset_y + thickness, 0])
          cylinder(display_guide_thickness, display_guide_radius - $tolerance/2, display_guide_radius - $tolerance/2);
      translate([0, -display_guide_radius, 0])
        cube([2*display_board_center_offset, 2*display_guide_radius, display_guide_thickness]);

    }
}

module board_grips(
  thickness,
  board_thickness,
  length,
  gap_width,
  grip_height,
  center=false
) {
  translate([center ? 0 : length/2, center ? 0 : board_thickness/2 + thickness, 0])
  for (i = [0:3])
  mirror([floor(i / 2), 0, 0])
    mirror([0, i % 2, 0])
      translate([gap_width/2, (board_thickness + $tolerance)/2, 0])
        cube([(length - gap_width)/2, thickness, grip_height]);
}

module screw_housing(
  screwed_depth,
  insert_depth,
  thickness,
  major_radius,
  minor_radius,
  head_radius,
  component = "BOTTOM",
  is_stacked = false,
  is_flipped = false,
  is_flat = true,
  align = "CENTER",
  mode = "COMPOSITE"
) {
  head_depth = head_radius - major_radius;
  true_insert_depth = max(head_depth + thickness, insert_depth);
  depth = screwed_depth + true_insert_depth;
  excess_depth = true_insert_depth - head_depth - thickness;
  alignment
    = align == "MINOR"
      ? minor_radius + $tolerance /2
    : align == "MAJOR"
      ? major_radius + $tolerance/2
    : align == "HEAD"
      ? head_radius + $tolerance/2
    : 0
    ;

  module positive(depth) {
    cylinder(depth, major_radius + thickness + $tolerance/2, major_radius + thickness + $tolerance/2);
    if (is_flat)
      translate([-major_radius - thickness - $tolerance/2, -major_radius - thickness - $tolerance/2, 0])
        cube([major_radius + thickness + $tolerance/2, 2*(major_radius + thickness) + $tolerance, depth]);
  }

  module bottom_positive() {
    positive(screwed_depth);
  }

  module bottom_negative() {
    cylinder(depth, minor_radius + $tolerance/2, minor_radius + $tolerance/2);
  }

  module top_positive() {
    positive(true_insert_depth);
  }

  module top_negative() {
    cylinder(thickness, major_radius + $tolerance/2, major_radius + $tolerance/2);
    translate([0, 0, thickness]) {
      cylinder(head_depth, major_radius + $tolerance/2, head_radius + $tolerance/2);
      translate([0, 0, head_depth])
        cylinder(excess_depth, head_radius + $tolerance/2, head_radius + $tolerance/2);
    }
  }

  module difference_mode(m = "COMPOSITE") {
    if (m == "NEGATIVE") {
      children(1);
    } else {
      difference() {
        children(0);
        if (m == "COMPOSITE")
          children(1);
      }
    }
  }

  translate ([alignment, 0, 0]) {
    if (component == "BOTTOM")
      translate([0, 0, is_stacked && is_flipped ? true_insert_depth : 0])
        difference_mode(mode) {
          bottom_positive();
          bottom_negative();
        }
    if (component == "TOP")
      translate([0, 0, is_stacked && !is_flipped ? screwed_depth : 0])
        translate([0, 0, is_flipped ? true_insert_depth : 0])
          mirror([0, 0, is_flipped ? 1 : 0])
            difference_mode(mode) {
              top_positive();
              top_negative();
            }
  }
}

module bar_clamp(
  thickness,
  bar_radius,
  screw_major_radius,
  screw_minor_radius,
  screw_head_radius,
  joint_clearance,
  joint_height,
  is_stacked = false,
  gap = 0,
  component = "ALL",
  explode = 20
) {
  // This is an unfortunate coupling to the screw module :/
  width = 2*(screw_major_radius + thickness) + $tolerance;
  true_inner_radius = bar_radius + $tolerance/2;
  outer_radius = thickness + true_inner_radius;

  module screw(mode, component) {
    screw_housing(outer_radius - gap/2, outer_radius - gap/2, thickness, screw_major_radius, screw_minor_radius, screw_head_radius, component = component, align = "MAJOR", mode = mode, is_flipped = true);
  }

  module double() {
    for(i = [0:1])
      translate([(1-i)*outer_radius*2, width/2, 0])
        mirror([i,0,0])
          children(0);
  }

  module x(c) {
    difference() {
      hull(){
        double()
          screw("POSITIVE", component = c);

        if (c == "BOTTOM")
          mirror([1, 0, 0])
            cube([joint_clearance - thickness, width, joint_height]);
      }
      double()
        screw("NEGATIVE", component = c);
      translate([outer_radius, 0, outer_radius])
        rotate([-90, 0, 0])
          cylinder(width, true_inner_radius, true_inner_radius);
    }
  }

  translate([joint_clearance - thickness, 0, 0]) {
    if (component == "BOTTOM" || component == "ALL")
      x("BOTTOM");

    if (component == "TOP" || component == "ALL")
      translate([0, 0, (component == "ALL" ? explode : 0) + (component == "ALL" || is_stacked ? 2*outer_radius : 0)])
        mirror([0, 0, component == "ALL" || is_stacked ? 1 : 0])
          x("TOP");
  }
}

housing(
  thickness = 2,
  pi_rod_radius = (2.75 - 0.05)/2,
  pi_rod_height = 16.5,
  pi_rod_spacing_x = 58,
  pi_rod_spacing_y = 23,
  pi_rod_clearance = 3.5,
  pi_solder_clearance = 2,
  button_shim_extension = 6,
  button_shim_height = 4,
  button_x = 8.7,
  button_opening_x = 6.7,
  button_opening_z = 4.25,
  button_offset = 16.75,
  display_extension = 2,
  display_height = 29,
  display_guide_radius = 1.6,
  display_guide_dist = 34,
  display_guide_offset_y = 3,
  display_board_thickness = 1.5,
  battery_length = 60,
  battery_width = 50,
  battery_thickness = 7.25,
  battery_guard_ratio = 0.2,
  sd_card_protrusion = 7/3,
  gps_board_offset = 6,
  gps_board_width = 82/3,
  gps_board_thickness = 1,
  gps_usb_width = 12.5,
  gps_safe_grip_depth = 4,
  power_cutout = 15,
  battery_housing_screw_major_radius = 1.5, // M3*12
  battery_housing_screw_minor_radius = 1.2,
  battery_housing_screw_head_radius = 2.75,
  bar_radius = 31.8/2,
  bar_clamp_gap = 1,
  bar_clamp_screw_major_radius = 1.5, // M3*12
  bar_clamp_screw_minor_radius = 1.2,
  bar_clamp_screw_head_radius = 3.2,
  stem_width = 46,
  stem_clearance = 10,
  $fn=60,
  $tolerance = 0.7
);
