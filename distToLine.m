function d = distToLine(p,u,q)
    d = norm(abs(cross(([q;0]-[p;0]),[u;0])))/norm([u;0]);