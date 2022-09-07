function plot_arrow_geoplot(begin_point,end_point,gx, varargin)
    if ~(isvector(begin_point) && length(begin_point)==2)
       error('begin_point is not a 2D vector') 
    end
    if ~(isvector(end_point) && length(end_point)==2)
       error('end_point is not a 2D vector') 
    end
    begin_point = begin_point(:)';
    end_point = end_point(:)';
    pivot_x = end_point(1);
    pivot_y = end_point(2);
    theta = 20;
    px = begin_point(1);
    py = begin_point(2);
    s = sind(theta);
    c = cosd(theta);
    px = (px - pivot_x)*0.4;
    py = (py - pivot_y)*0.4;
    xnew = px * c - py * s;
    ynew = px * s + py * c;
    px = xnew + pivot_x;
    py = ynew + pivot_y;
    theta = -20;
    px2 = begin_point(1);
    py2 = begin_point(2);
    s = sind(theta);
    c = cosd(theta);
    px2 = (px2 - pivot_x)*0.4;
    py2 = (py2 - pivot_y)*0.4;
    xnew = px2 * c - py2 * s;
    ynew = px2 * s + py2 * c;
    px2 = xnew + pivot_x;
    py2 = ynew + pivot_y;
    % plot
    geoplot(gx, [begin_point(1) end_point(1)],[begin_point(2) end_point(2)],... % line
            [px end_point(1)],[py end_point(2)],... % arrow end first part
            [px2 end_point(1)],[py2 end_point(2)],varargin{:}) % arrow end second part
end