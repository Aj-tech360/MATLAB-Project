function height_at_building = plane_h2(user_runway_length, x_acc1, x_acc2, building_base1, distance_takeoff_feet, y_acc1, y_acc2, ang1_int_xvel, ang1_int_yvel, ang2_int_xvel, flight_xs_between, ang2_int_yvel, flight_ys_ang1, flight_ys_ang2) 
%PLANE_H2 finds the plane's height
%HEIGHT_AT_BUILDING = PLANE_H2(BUILDING_BASE1, TAKEOFF_DISTANCE_FEET, FLIGHT_XS_AF_ANG2, ANG2_INT_XVEL, X_ACC2, FLIGHT_YS_ANG2, ANG2_INT_YVEL, Y_ACC2)


%Benjamin Sites

%find delta x position
delta_x = building_base1 - distance_takeoff_feet;

%find c for quadratic equation 
quad_c = building_base1 - distance_takeoff_feet;

%caluate height at building
if delta_x > user_runway_length && delta_x <= flight_xs_between
    %calulate a and b for quadratic eqation 
    quad_a = 1/2 * x_acc1;
    quad_b = ang1_int_xvel; 
    
    %calcuate time using quadratic equation
    time_at_build_x_wpls = (-quad_b + sqrt(quad_b^2 + 4 * quad_a * quad_c)) / (2 * quad_a);
    time_at_build_x_wmin = (-quad_b - sqrt(quad_b^2 + 4 * quad_a * quad_c)) / (2 * quad_a);
    
    %find correct time value
    if time_at_build_x_wpls ==abs(time_at_build_x_wpls)
        time_at_build_x_true = time_at_build_x_wpls;
    else
        time_at_build_x_true = time_at_build_x_wmin;
    end
    
    %calulate height at building
    height_at_building = flight_ys_ang1 + ang1_int_yvel * time_at_build_x_true + 1/2 * y_acc1 *time_at_build_x_true^2; 
else
    quad_a = 1/2 * x_acc2;
    quad_b = ang2_int_xvel; 
    
    time_at_build_x_wpls = (-quad_b + sqrt(quad_b^2 + 4 * quad_a * quad_c)) / (2 * quad_a);
    time_at_build_x_wmin = (-quad_b - sqrt(quad_b^2 + 4 * quad_a * quad_c)) / (2 * quad_a);
    
    if time_at_build_x_wpls == abs(time_at_build_x_wpls)
        time_at_build_x_true = time_at_build_x_wpls;
    else
        time_at_build_x_true = time_at_build_x_wmin;
    end
    
    height_at_building = flight_ys_ang2 + ang2_int_yvel * time_at_build_x_true + 1/2 * y_acc2 *time_at_build_x_true^2; 
end









