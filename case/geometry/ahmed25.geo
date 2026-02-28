

SetFactory("OpenCASCADE");

// Parameters
L  = 1.044;
H  = 0.288;
W  = 0.389;
Ls = 0.222;
theta = 25*Pi/180;

Lbox   = L - Ls;
Hslant = Ls*Tan(theta);

// ----------------------------
// Front rectangular block
// ----------------------------
Box(1) = {0, -W/2, 0, Lbox, W, H};

// ----------------------------
// Rear slanted block
// ----------------------------

// Bottom rectangle
Point(101) = {Lbox, -W/2, 0};
Point(102) = {L,    -W/2, 0};
Point(103) = {L,     W/2, 0};
Point(104) = {Lbox,  W/2, 0};

// Top slanted edge
Point(105) = {Lbox, -W/2, H};
Point(106) = {L,    -W/2, H - Hslant};
Point(107) = {L,     W/2, H - Hslant};
Point(108) = {Lbox,  W/2, H};

// Create rear volume via ruled surfaces
Line(201) = {101,102};
Line(202) = {102,103};
Line(203) = {103,104};
Line(204) = {104,101};

Line(205) = {105,106};
Line(206) = {106,107};
Line(207) = {107,108};
Line(208) = {108,105};

Line(209) = {101,105};
Line(210) = {102,106};
Line(211) = {103,107};
Line(212) = {104,108};

Line Loop(301) = {201,202,203,204};
Plane Surface(401) = {301};

Line Loop(302) = {205,206,207,208};
Plane Surface(402) = {302};

Line Loop(303) = {201,210,-205,-209};
Plane Surface(403) = {303};

Line Loop(304) = {202,211,-206,-210};
Plane Surface(404) = {304};

Line Loop(305) = {203,212,-207,-211};
Plane Surface(405) = {305};

Line Loop(306) = {204,209,-208,-212};
Plane Surface(406) = {306};

Surface Loop(500) = {401,402,403,404,405,406};
Volume(2) = {500};

// ----------------------------
// Fuse both volumes
// ----------------------------
BooleanUnion{ Volume{1}; Delete; }{ Volume{2}; Delete; }
//+
Show "*";


// =====================================================
// Wind Tunnel Domain
// =====================================================

Lup   = 3*L;
Ldown = 8*L;
Hdom  = 5*L;
Wdom  = 5*L;

xmin = -Lup;
xmax = L + Ldown;
ymin = -Wdom;
ymax =  Wdom;
zmin = 0;
zmax = Hdom;

// Wind tunnel dimensions
Lbody = 1.044;

xmin = -3*Lbody;
xmax =  5*Lbody;

ymin = -1*Lbody;
ymax =  1*Lbody;

zmin = 0;
zmax = 2*Lbody;

Box(1000) = {
  xmin, ymin, zmin,
  xmax - xmin,
  ymax - ymin,
  zmax - zmin
};


// Subtract Ahmed body from box
fluid[] = BooleanDifference
{
  Volume{1000}; Delete;
}
{
  Volume{1}; Delete;
};


Physical Volume("fluid") = {1000};

Physical Surface("inlet")  = {13};
Physical Surface("outlet") = {8};
Physical Surface("top")    = {10};
Physical Surface("bottom") = {12};
Physical Surface("side1")  = {9};
Physical Surface("side2")  = {11};

Physical Surface("body") = {1, 2, 3, 4, 6, 7};


// =======================
// Global mesh settings
// =======================
Mesh.CharacteristicLengthMin = 0.05;
Mesh.CharacteristicLengthMax = 0.2;


// =======================
// Refinement near body
// =======================

Field[1] = Distance;
Field[1].FacesList = {1, 2, 3, 4, 6, 7};   // body surfaces

Field[2] = Threshold;
Field[2].InField = 1;
Field[2].SizeMin = 0.02;   // very fine near body
Field[2].SizeMax = 0.2;    // coarse far away
Field[2].DistMin = 0.05;   // within 5 cm → fine
Field[2].DistMax = 0.5;    // beyond 50 cm → coarse

Background Field = 2;
