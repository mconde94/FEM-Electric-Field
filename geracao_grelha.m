function [p,t] = geracao_grelha

fd=inline('ddiff(drectangle(p,-0.5,0.5,-0.5,0.5),dcircle(p,-0.5,-0.5,0.5))','p');

fh = @(p) 0.5 + 0.5*dcircle(p,-0.5,-0.5,0.5);

pfix = [-0.50,  0.00; ...
    -0.50,  0.25; ...
    -0.50,  0.50; ...
    0.00,  0.50; ...
    0.50,  0.50; ...
    0.50,  0.25; ...
    0.50,  0.00; ...
    0.50, -0.25; ...
    0.50, -0.50; ...
    0.25, -0.50; ...
    0.00, -0.50];

ang = 15;

theta = ang;

while theta < 90
    
    xp = -0.5 + 0.5*cos(theta*pi/180);
    yp = -0.5 + 0.5*sin(theta*pi/180);
    
    pfix = [pfix; xp, yp];
    
    theta = theta + ang;
    
end

[p,t] = distmesh2d(fd,fh,0.05,[-0.5,-0.5;0.5,0.5],pfix);

end
