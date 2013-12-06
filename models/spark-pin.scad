minkowski() {
  linear_extrude(height=0.01)
    import("mof-spark.dxf");
  cylinder(r1=3, r2=0.1, h=5, $fn=6);
}
