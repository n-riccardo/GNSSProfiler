function d = PointLineDistance3D(P, A, v)
    % PointLineDistance3D computes the shortest distance from a 3D point to a line
    %
    % d = pointLineDistance(P, A, v)
    %
    % Inputs:
    %   P - 1x3 vector representing the coordinates of the point [Px, Py, Pz]
    %   A - 1x3 vector representing a point on the line [Ax, Ay, Az]
    %   v - 1x3 vector representing the direction of the line [vx, vy, vz]
    %
    % Output:
    %   d - Shortest distance from the point P to the line defined by (A, v)
    %
    % Ensure v is a unit vector
    v = v / norm(v);
    
    % Compute vector from A to P
    AP = P - A;

    % project AP into v
    AQ=dot(AP,v)*v;
    
    d=sqrt(norm(AP)^2-norm(AQ)^2);
    
end


