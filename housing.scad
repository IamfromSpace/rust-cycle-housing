use <h_buttons.scad>;

module housing(
  thickness, // general thickness of walls
  pi_rod_radius, // radius of the screw holes on the pi
  pi_rod_height, // height of the rods to pass through the pi, button shim, and the adapter
  pi_rod_spacing_x, // distance from the screw hole centers of the pi along the x axis
  pi_rod_spacing_y, // distance from the screw hole centers of the pi along the y axis
  pi_rod_clearance, // distance from the pi screw hole centers to the edge of the board
  pi_solder_clearance, // height of the solder joints on the underside of the pi
  pi_board_thickness, // thickness of the pi board
  pi_to_adapter_spacing, // the space between the pi and the adapter (neither board thickness is considered)
  button_shim_extension, // how much further the button shim sticks out beyond the pi
  button_shim_height, // distance from the bottom of the pi to the center of the button shim button
  button_x, // total width of a button
  button_opening_x, // width of the opening to reveal the button
  button_offset, // distance from center button E to its closest side of the pi board (measured along the length of the pi).
  button_impression_thickness, // thickness of the button backing
  button_throw, // how much travel is required to depress the button
  display_extension, // how much further the display sticks out beyond the button shim
  display_height, // distance between the bottom of the pi board and the bottom of the display board
  board_screw_major_radius, // radius of the screw holes on the display board
  board_screw_minor_radius, // radius of the screw holes on the display board
  board_screw_head_radius, // radius of the screw holes on the display board
  board_screw_depth, // How deep screws that secure boards will go
  display_guide_dist, // distance between the screw holes along the button-side edge
  display_guide_offset_y, // distance between top of the board the screw holes
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
  board_screw_washer_height = screw_housing_top_height(
    0,
    board_screw_head_radius,
    thickness,
    board_screw_major_radius
  );
  pi_offset_z = max(pi_solder_clearance, board_screw_washer_height + $tolerance/2);
  pi_offset_y = gps_board_thickness/2 + thickness + gps_board_offset + $tolerance;
  inner_y = pi_offset_y + button_shim_extension + pi_rod_spacing_y + 2*pi_rod_clearance + button_impression_thickness + $tolerance;
  pi_length_x = pi_rod_spacing_x + 2*pi_rod_clearance;
  pi_offset_x = sd_card_protrusion;
  inner_x = sd_card_protrusion + pi_length_x + $tolerance + power_cutout + 2*thickness + $tolerance;

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
          translate([(1 - i) * (joining_plane_x + 2 * thickness), joining_plane_y/2 + thickness + $tolerance/2, 0])
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

  module pi_spacer(component = "ALL") {
    double_ended_screw_housing(
      thickness,
      pi_to_adapter_spacing,
      board_screw_major_radius,
      board_screw_minor_radius,
      board_screw_head_radius,
      // NOTE: We use explode to demonstrate spacing from the board
      explode = pi_board_thickness + explode,
      component = component
    );
  }

  module bw(component) {
    button_wall(
      thickness,
      joining_plane_x + 2*thickness,
      display_height + pi_offset_z,
      button_x,
      button_opening_x,
      pi_offset_x + button_offset + thickness + $tolerance/2,
      button_shim_height + pi_offset_z,
      button_impression_thickness,
      button_throw,
      display_extension - button_impression_thickness - $tolerance,
      board_screw_minor_radius,
      board_screw_depth,
      display_guide_dist,
      display_guide_offset_y,
      pi_offset_x + pi_length_x/2 + thickness + $tolerance/2,
      component = component,
      explode = explode
    );
  }

  if (component == "MAIN" || component == "ALL") {
    color([1, 1, 1, 0.25]) {
      translate([-thickness - $tolerance/2, -thickness - $tolerance/2, 0])
        cube([thickness, 2*thickness + inner_y, display_height + pi_offset_z]);

      translate([-thickness - $tolerance/2, -thickness - $tolerance/2, 0])
        cube([2*thickness + inner_x, thickness, display_height + pi_offset_z]);

      translate([joining_plane_x - $tolerance/2 - 2*thickness - $tolerance, -thickness - $tolerance/2, 0])
        difference() {
          cube([3*thickness + $tolerance, 2*thickness + inner_y, display_height + pi_offset_z]);
          translate([thickness, 0, 0])
            cube([thickness + $tolerance, 2*thickness + inner_y, display_height + pi_offset_z]);
          translate([0, 2*thickness, thickness])
            cube([3*thickness + $tolerance, -2*thickness + inner_y, display_height + pi_offset_z -thickness]);
        }
    }

    translate([0, 0, -thickness]) {
      difference() {
        translate([-thickness - $tolerance/2, -thickness - $tolerance/2, 0])
          cube([joining_plane_x + 2*thickness, joining_plane_y + 2*thickness, thickness]);
        translate([inner_x - power_cutout - 2*thickness, 0, 0])
          cube([power_cutout, inner_y, thickness]);
      }

      for (i = [0,1])
        translate([(1 - i) * (joining_plane_x + 2 * thickness) - thickness - $tolerance/2, joining_plane_y/2, 0])
          rotate([0, 0, i * 180])
            battery_housing_screw_housing("TOP");
    }

    translate([pi_offset_x + pi_rod_clearance, pi_offset_y + pi_rod_clearance, 0])
      for (x = [0, 1]) {
        translate([x*pi_rod_spacing_x, 0, 0]) {
          translate([0, pi_rod_spacing_y, 0]) {
            cylinder(pi_rod_height + pi_offset_z, pi_rod_radius - $tolerance/2, pi_rod_radius - $tolerance/2);
            cylinder(pi_offset_z, pi_rod_clearance, pi_rod_clearance);
          }

          if (component == "ALL")
            translate([0, 0, $tolerance/2 + explode])
              pi_spacer();
        }
      }

    translate([-thickness - $tolerance/2, inner_y - $tolerance/2, 0])
      bw(component == "ALL" ? "ALL" : "WALL");

    // TODO: These fit nicely, but the vibrations jostle it out of the grips.
    // They need to be tighter (half tolerance, no tolerance?  Is there a
    // common rule that can be applied for these things?), or there needs to be
    // pressure from the top of the housing.
    translate([pi_offset_x, 0, 0])
      board_grips(thickness, gps_board_thickness, gps_board_width, gps_usb_width, gps_safe_grip_depth);
  }

  if (component == "PI_SPACER_BOTTOM")
    pi_spacer("BOTTOM");

  if (component == "PI_SPACER_MIDDLE")
    pi_spacer("MIDDLE");

  if (component == "PI_SPACER_TOP")
    pi_spacer("TOP");

  if (component == "BUTTON")
    bw("BUTTON");
}

module button_wall(
  thickness, // wall thickness
  length, // how long the wall should be
  height, // height of the wall
  button_x, // total width of a button
  button_opening_x, // width of the button opening
  button_offset_x, // offset for the buttons (wall edge to first button center)
  button_offset_z, // offset for the buttons (wall bottom to button center)
  button_impression_thickness, // how thick the backing of the button is
  button_throw, // how much travel is required to depress the button
  extension, // how much further the top of the wall should extend
  screw_inner_radius, // radius of the screw holes on the board
  screw_depth, // how deep the board mounting screws will go into the wall
  screw_dist, // distance between the screw holes along the button-side edge
  screw_offset_y, // distance between top of the board the screw holes
  board_center_offset, // how far the center of the board is from the origin
  component = "ALL",
  explode = 20,
) {
  screw_center_y = extension - screw_offset_y;
  screw_true_inner_radius = screw_inner_radius + $tolerance/2;
  screw_true_outer_radius = thickness + screw_true_inner_radius;

  function single_button_def(is_positive) =
    HButton(
      radius = button_opening_x/2 - (is_positive ? $tolerance/2 : 0),
      depth = $tolerance/2 + button_throw + thickness + button_impression_thickness + $tolerance/2,
      impression_thickness = button_impression_thickness,
      x_align = "BOTTOM"
    );
  button_opening_z = get_height(single_button_def(false));

  module button_row(is_positive) {
    for (i = [0:4])
      translate([i * button_x + button_offset_x, 0, button_offset_z - button_opening_z/2])
        rotate([-90, -90, 0])
          h_button(single_button_def(is_positive));
  }

  module left_right() {
    for(i = [-1,1])
      translate([board_center_offset + i * screw_dist/2, 0, 0])
        children();
  }

  if (component == "BUTTON")
    h_button(single_button_def(true));

  if (component == "ALL")
    translate([0, -explode, $tolerance/2])
      button_row(true);

  if (component == "ALL" || component == "WALL") {
    difference() {
      cube([length, thickness, button_offset_z + button_opening_z/2]);
      button_row(false);
    }

    button_shim_bottom_to_display_bottom = height - (button_offset_z + button_opening_z/2);

    translate([0, 0, button_offset_z + button_opening_z/2]) {
      difference() {
        union() {
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


          intersection() {
            translate([0, screw_center_y, 0])
              left_right() {
                cylinder(button_shim_bottom_to_display_bottom, screw_true_outer_radius, screw_true_outer_radius);

                translate([-screw_true_outer_radius, 0, 0])
                  cube([2*screw_true_outer_radius, -screw_center_y, button_shim_bottom_to_display_bottom]);
              }

            rotate([90, 0, 0])
              rotate([0, 90, 0])
              linear_extrude(length)
              polygon(
                  [ [0,0]
                  , [0, button_shim_bottom_to_display_bottom]
                  , [screw_center_y - screw_true_outer_radius, button_shim_bottom_to_display_bottom]
                  , [screw_center_y - screw_true_outer_radius, button_shim_bottom_to_display_bottom - screw_depth]
                  ]
                  );
          }
        }

        translate([0, screw_center_y, button_shim_bottom_to_display_bottom - screw_depth - $tolerance/2])
          left_right()
            cylinder(screw_depth + $tolerance/2 + $fudge, screw_true_inner_radius, screw_true_inner_radius);
      }
    }
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

function screw_housing_top_height(
  insert_depth,
  head_radius,
  thickness,
  major_radius,
) = max(head_radius - major_radius + thickness, insert_depth);

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
  true_insert_depth = screw_housing_top_height(
    insert_depth,
    head_radius,
    thickness,
    major_radius
  );
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

module double_ended_screw_housing(
  thickness,
  spacing,
  major_radius,
  minor_radius,
  head_radius,
  insert_depth = 0,
  component = "ALL",
  explode = 20,
) {
  true_insert_depth = screw_housing_top_height(
    insert_depth,
    head_radius,
    thickness,
    major_radius
  );

  module sh(component) {
    screw_housing(
      screwed_depth = spacing,
      insert_depth = true_insert_depth,
      thickness = thickness,
      major_radius = major_radius,
      minor_radius = minor_radius,
      head_radius = head_radius,
      component = component == "MIDDLE" ? "BOTTOM" : "TOP",
      is_stacked = component != "TOP",
      is_flipped = component != "TOP",
      is_flat = false,
      align = "CENTER",
      mode = "COMPOSITE"
    );
  }

  if (component == "ALL" || component == "BOTTOM")
    sh("BOTTOM");

  translate([0, 0, component == "ALL" ? explode : 0]) {
    if (component == "ALL" || component == "MIDDLE")
      sh("MIDDLE");

    translate([0, 0, component == "ALL" ? true_insert_depth + spacing + explode : 0])
      if (component == "ALL" || component == "TOP")
        sh("TOP");
  }
}

housing(
  // TODO: For some test prints, there was not enough contact from the bottom
  // wall to the side wall, making the sidewall snap off.  If this happens at
  // full size, then it may make sense to create a wider base that narrows.
  thickness = 2,
  pi_rod_radius = (2.75 - 0.05)/2,
  pi_rod_height = 16.5,
  pi_rod_spacing_x = 58,
  pi_rod_spacing_y = 23,
  pi_rod_clearance = 3.5,
  pi_solder_clearance = 2,
  pi_board_thickness = 1.5,
  pi_to_adapter_spacing = 13,
  button_shim_extension = 6,
  button_shim_height = 7,
  button_x = 8.7,
  button_opening_x = 4.2,
  button_offset = 20.1,
  button_impression_thickness = 1,
  button_throw = 0.2,
  display_extension = 2.8,
  display_height = 27,
  board_screw_major_radius = 2/2, // M2*10
  board_screw_minor_radius = 1.54/2,
  board_screw_head_radius = 3.5/2,
  board_screw_depth = 5,
  display_guide_dist = 34,
  display_guide_offset_y = 3,
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
  power_cutout = 15.3,
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
  $tolerance = 0.7,
  $fudge = 0.00001
);
