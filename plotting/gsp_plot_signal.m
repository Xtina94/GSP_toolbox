function gsp_plot_signal(G,signal,param)
%GSP_PLOT_SIGNAL  Plot a graph signal in 2D or 3D
%   Usage:  gsp_plot_signal(G,signal);
%           gsp_plot_signal(G,signal,param);
%
%   Input parameters:
%         G          : Graph structure.
%         signal     : Graph signal.
%         param      : Optional variable containing additional parameters.
%   Output parameters:
%         none
%
%   'gsp_plot_signal(G,f)' plots a graph signal in 2D or 3D, using the adjacency 
%   matrix (G.A), the plotting coordinates (G.coords), the 
%   coordinate limits (G.plotting.limits), the edge width (G.plotting.edge_width), the 
%   edge color (G.plotting.edge_color), the edge style (G.plotting.edge_style), and the 
%   vertex size (G.vertex_size).
%
%   Example:
%
%          G = gsp_ring(15);
%          f = sin((1:15)*2*pi/15);
%          gsp_plot_signal(G,f)
%
%   Additional parameters
%   ---------------------
%    param.show_edges : Set to 0 to only draw the vertices. (default G.Ne < 10000 )
%    param.cp         : Camera position for a 3D graph.
%    param.vertex_size*: Size of circle representing each signal component.
%    param.colorbar   : Set to 0 to not show the colorbar
%    param.climits    : Limits of the colorbar
%    param.vertex_highlight*: highlight a vertex numbered by
%                          vertex_highlight.
%    param.bar        : 1 Display bar for the graph. 0 Display color
%                          points. (default 1);
%    param.bar_width  : Width of the bar (default 1)
%
%   See also: gsp_plot_graph gsp_plot_signal_spectral
%
%
%   Url: http://lts2research.epfl.ch/gsp/doc/plotting/gsp_plot_signal.php

% Copyright (C) 2013-2014 Nathanael Perraudin, Johan Paratte, David I Shuman.
% This file is part of GSPbox version 0.3.1
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% If you use this toolbox please kindly cite
%     N. Perraudin, J. Paratte, D. Shuman, V. Kalofolias, P. Vandergheynst,
%     and D. K. Hammond. GSPBOX: A toolbox for signal processing on graphs.
%     ArXiv e-prints, Aug. 2014.
% http://arxiv.org/abs/1408.5781


% Author :  Nathanael Perraudin, David I Shuman
% Testing: test_plotting

  

% Handling optional inputs
if nargin < 3
   param = struct;
end

if sum(abs(imag(signal(:))))>1e-10
   error('GSP_PLOT_GRAPH: can not display complex signal') 
end

signal = real(signal);

if ~isfield(param,'show_edges'), param.show_edges = G.Ne < 10000; end
if ~isfield(param,'bar'), param.bar = 0; end
if ~isfield(param,'bar_width'), param.bar_width = 1; end
if ~isfield(param,'vertex_highlight'), param.vertex_highlight = 0; end
if ~isfield(param,'vertex_size'), 
    if ~isfield(G.plotting,'vertex_size')
        param.vertex_size=500; 
    else
        param.vertex_size=G.plotting.vertex_size*10;
    end
else
    param.vertex_size = param.vertex_size*10; 
end

if ~isfield(param,'colorbar'), param.colorbar = 1; end
if ~isfield(param,'climits')
    cmin=1.01*min(signal)-eps;
    cmax=1.01*max(signal)+eps;
    param.climits=[cmin,cmax];
end
if ~isfield(param,'cp')
    if isfield(G.plotting, 'cp')
       param.cp = G.plotting.cp; 
    else
       param.cp=[-6   -3  160]; 
    end
    
end

if ~isfield(G,'coords')
    error('GSP_PLOT_GRAPH: Cannot plot a graph without coordinate!')
end

% Clear axes
cla;
G = gsp_graph_default_plotting_parameters(G);

hold on;


if param.show_edges
%         gplot23D(G.A,G.coords,G.plotting.edge_style,...
%             'LineWidth',G.plotting.edge_width,'Color',G.plotting.edge_color); 
    [ki,kj]=find(G.A);
    if G.directed

        if size(G.coords,2)==2
            In  = [G.coords(ki,1),G.coords(ki,2)]; 
            Fin = [G.coords(kj,1),G.coords(kj,2)]; 
            V=Fin-In;
            quiver(G.coords(ki,1),G.coords(ki,2),V(:,1),V(:,2),0,...
                    '-r','LineWidth',G.plotting.edge_width);
        else
            In  = [G.coords(ki,1),G.coords(ki,2),G.coords(ki,3)]; 
            Fin = [G.coords(kj,1),G.coords(kj,2),G.coords(kj,3)]; 
            V=Fin-In;
            quiver3(G.coords(ki,1),G.coords(ki,2),G.coords(ki,3),...
                V(:,1),V(:,2),V(:,3),0,...
                    '-r','LineWidth',G.plotting.edge_width);
        end
    else
        if size(G.coords,2) == 2 
            plot([G.coords(ki,1)';G.coords(kj,1)'],...
                [G.coords(ki,2)';G.coords(kj,2)'],...
                G.plotting.edge_style, 'LineWidth',G.plotting.edge_width,...
                'Color',G.plotting.edge_color);
        else
                plot3([G.coords(ki,1)';G.coords(kj,1)'],...
                [G.coords(ki,2)';G.coords(kj,2)'],...
                [G.coords(ki,3)';G.coords(kj,3)'],...
                G.plotting.edge_style, 'LineWidth',G.plotting.edge_width,...
                'Color',G.plotting.edge_color);
        end
    end
end

if size(G.coords,2) == 2
    if param.bar
        ind = find(signal < 0);
        plot3([G.coords(ind,1)'; G.coords(ind,1)'],...
            [G.coords(ind,2)'; G.coords(ind,2)'],...
            [zeros(1,length(ind)); reshape(signal(ind),1,[])],...
            G.plotting.edge_style, 'LineWidth',param.bar_width,'color','k');
        ind = find(signal >= 0);
        plot3([G.coords(ind,1)'; G.coords(ind,1)'],...
            [G.coords(ind,2)'; G.coords(ind,2)'],...
            [zeros(1,length(ind)); reshape(signal(ind),1,[])],...
            G.plotting.edge_style, 'LineWidth',param.bar_width,'color','b');
        if param.vertex_highlight > 0
            vh = param.vertex_highlight;
            plot3([G.coords(vh,1)'; G.coords(vh,1)'],...
                [G.coords(vh,2)'; G.coords(vh,2)'],...
                [zeros(1,length(vh)); reshape(signal(vh),1,[])],...
                G.plotting.edge_style, 'LineWidth',2*param.bar_width,'color','m');

        end   
    else
        scatter(G.coords(:,1),G.coords(:,2), ...
            param.vertex_size, signal, '.');
        if param.vertex_highlight > 0
            vh = param.vertex_highlight;
            scatter(G.coords(vh,1),G.coords(vh,2), ...
                param.vertex_size/3, 'ok');

        end   
    end


else %if size(G.coords,2) == 3
    scatter3(G.coords(:,1),G.coords(:,2),G.coords(:,3),...
                    param.vertex_size,signal,'.');
    if param.vertex_highlight > 0
        vh = param.vertex_highlight;
        scatter(G.coords(vh,1),G.coords(vh,2),G.coords(vh,3), ...
            param.vertex_size, 'ok');

    end             

end


axis(G.plotting.limits)

if size(G.coords,2)==3 || param.bar
    set(gca,'CameraPosition',param.cp);
end

if ~param.bar
    caxis(param.climits);

    if param.colorbar
        colorbar;
    end
end

axis off;
hold off;


end
