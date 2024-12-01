
/* [Tag] */

// Overall height of the tag.
HEIGHT = 50;

// Overall width of the tag.
WIDTH = 100;

// Thickness of the base part.
BASE_THICKNESS = 4;

// How much to round off the corners of the tag.
CORNER_ROUNDING = 5;

/* [Label] */

// Thickness of the text.
TEXT_THICKNESS = 2;

// The font size to use for the text.
FONT_SIZE = 10;

// The font to use for the text.
FONT_FACE = "Liberation Sans";

// How wide to make the text.
TEXT_WIDTH = 90;

// How tall to make each line of text.
LINE_HEIGHT = 1.2;

// The first line of text of the label.
LABEL1="";
// The second line of text of the label (optional).
LABEL2="";
// The third line of text of the label (optional).
LABEL3="";
LABELS = LABEL3 != "" ? [ LABEL1, LABEL2, LABEL3 ] :
         LABEL2 != "" ? [ LABEL1, LABEL2 ] :
         LABEL1 != "" ? [ LABEL1 ] :
         [ "Valve", "Shut-Off" ];

/* [Slots] */

// Height of the slots included for zip-ties.
SLOT_HEIGHT = 2;

// Width of the slots included for zip-ties.
SLOT_WIDTH = 5;

// How much to round off the zip-tie slots.
SLOT_ROUNDING = 1;

// Whether or not to include the corner slots.
INCLUDE_CORNER_SLOTS = true;

// How far to from the left/right should the slots be placed?
CORNER_SLOT_INSET_X = 6;

// How far from the top/bottom should the corner slots be placed?
CORNER_SLOT_INSET_Y = 4;

// Include the left end slot?
INCLUDE_LEFT_END_SLOT = true;

// Include left end hole?
INCLUDE_LEFT_END_HOLE = false;

// Include the right end slot?
INCLUDE_RIGHT_END_SLOT = true;

// Include left end hole?
INCLUDE_RIGHT_END_HOLE = false;

END_HOLE_DIAMETER = 5;

// How far from the edges should the end slots/holes be placed?
END_HOLE_INSET = 4;

include <BOSL2/std.scad>;

$fs = $preview ? 1 : 0.1;
$fa = $preview ? 3 : 0.1;

module make_labels(
  // vcenter = false,
) {
  union() {
    translate ( [0,-(len(LABELS)-1)*FONT_SIZE*LINE_HEIGHT/2,0] )
      for ( i = [ 0 : len(LABELS)-1 ] ) {
        translate( [ 0, ( len(LABELS)-1-i ) * FONT_SIZE * LINE_HEIGHT, 0 ] )
          text(
            text = LABELS[i],
            size = FONT_SIZE,
            halign = "center",
            valign = "center",
            spacing = 1,
            font = FONT_FACE
          );
      }
  }
}

module slot( vertical = false ) {
  translate( [ 0, 0, -1 ] )
    cuboid(
      [
        vertical ? SLOT_HEIGHT : SLOT_WIDTH,
        vertical ? SLOT_WIDTH : SLOT_HEIGHT,
        BASE_THICKNESS + 2
      ],
      rounding = SLOT_ROUNDING,
      edges = "Z",
      anchor = BOTTOM
    );
}

module hole() {
  translate( [ 0, 0, -1 ] )
    cylinder( END_HOLE_DIAMETER / 2, BASE_THICKNESS + 2 );
}

module corner_slots() {
  offset_w = WIDTH / 2 - CORNER_SLOT_INSET_X;
  offset_h = HEIGHT / 2 - CORNER_SLOT_INSET_Y;
  union() {
    translate( [ 0+offset_w, 0+offset_h, 0 ] ) slot( false );
    translate( [ 0-offset_w, 0-offset_h, 0 ] ) slot( false );
    translate( [ 0+offset_w, 0-offset_h, 0 ] ) slot( false );
    translate( [ 0-offset_w, 0+offset_h, 0 ] ) slot( false );
  }
}

module end_slots() {
  offset = WIDTH / 2 - END_HOLE_INSET;
  union() {
    if ( INCLUDE_RIGHT_END_HOLE ) {
      translate( [ 0+offset, 0, 0 ] ) hole();
    } else if ( INCLUDE_RIGHT_END_SLOT ) {
      translate( [ 0+offset, 0, 0 ] ) slot( true );
    }
    if ( INCLUDE_LEFT_END_HOLE ) {
      translate( [ 0-offset, 0, 0 ] ) hole();
    } else if ( INCLUDE_LEFT_END_SLOT ) {
      translate( [ 0-offset, 0, 0 ] ) slot( true );
    }
  }
}

module slots() {
  corner_slots();
  end_slots();
}

module make_base() {
  difference() {
    cuboid(
      [ WIDTH, HEIGHT, BASE_THICKNESS ],
      rounding = CORNER_ROUNDING,
      edges = "Z",
      anchor = BOTTOM
    );
    slots();
  }
}

module make_label() {
  translate( [ 0, 0, BASE_THICKNESS ] )
    linear_extrude( height = TEXT_THICKNESS )
      make_labels();
    /*
      drawWrappedText(
        LABEL,
        font = "Liberation Sans",
        size = FONT_SIZE,
        spacing = 1,
        linespacing = 1,
        indent = 0,
        width = TEXT_WIDTH,
        halign="justify",
        valign="justify"
      );
    */
}

union() {
  color( "white" ) make_base();
  color( "black" ) make_label();
}
