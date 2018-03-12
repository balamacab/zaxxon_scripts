%% Copyright (C) 1996, 1997 John W. Eaton
%%
%% This file is part of Octave.
%%
%% Octave is free software; you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2, or (at your option)
%% any later version.
%%
%% Octave is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%% General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with Octave; see the file COPYING.  If not, write to the Free
%% Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
%% 02110-1301, USA.
%%
%% $Id: histc.m,v 1.2 2008/10/02 09:29:41 peterlin Exp $

%% -*- texinfo -*- @deftypefn {Function File} {} histc (@var{data},
%% @var{edges}) Count the number of values in vector @var{data} that
%% fall between the elements in the @var{edges} vector, and return a
%% vector of counts of the same length as @var{edges}.
%%
%% The element @var{k} in the output vector counts the elements of
%% @var{data} satisfying @math{edges(k) <= data(i) < edges(k+1)}.  The
%% last element of the output vector counts the elements of @var{data}
%% equal to @var{edges(end)}. Values outside the values in @var{edges}
%% are not counted. Use @var{-inf} and @var{inf} in edges to include all
%% non-@var{NaN} values.
%%
%% The vector @var{edges} which must contain monotonically nondecreasing
%% values. No elements of @var{data} can be complex. @end deftypefn
%%
%% @seealso{hist}

function [freq bin]= mihistc (data, edges)

  if (nargin ~= 2)
    usage ('histc (data, edges)');
  endif

  if (!isreal (data))
    error ("histc: no elements of the first argument can be complex");
  endif

  if (isvector(edges))
    tmp = sort(edges);
    if (any(tmp != edges))
      warning ("histc: edge values not sorted on input");
      edges = tmp;
    endif
  else
    error ("histc: the second argument must be a vector");
  endif

  bin = zeros(1,length(data));
  
  freq = zeros(length(edges), 1);
  for k = 1:length(edges)-1
    freq(k) = length(data(data >= edges(k) & data < edges(k+1)));
  endfor
  freq(end) = length(data(data == edges(end)));
 
  edges=[edges;inf];
  for k = 1:length(edges)-1
 	bin(((data >= edges(k)) & (data < edges(k+1))))=k;
  endfor
  
 
 
endfunction 
