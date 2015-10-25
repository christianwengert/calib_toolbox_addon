function a = angle2Vect(v1,v2)
    if(norm(v1)==0 | norm(v2) == 0)
        a = 0;
    else
        a = acos(norm(dot(v1,v2))/(norm(v1)*norm(v2)));
    end