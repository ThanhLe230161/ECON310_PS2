%% File Info.

%{

    simulate_2.m
    ----------
    This code simulates the model.

%}

%% Simulate classs
classdef simulate_2
    methods(Static)
  %% Set up
  function sim = lc(par,sol)
  % unpack
  T      = par.T;        % should be 50
  NN     = par.NN;       % e.g. 3000
  tr     = par.tr;       % retirement age
  agrid  = par.agrid;    % asset grid (size 300×1)
  cpol   = sol.c;        % T-period policy c(a_idx, t, y_idx)
  apol   = sol.a;        % same for a′
  ygrid  = par.ygrid;    % income grid
  pmat   = par.pmat;     % y-transition
  kappa  = par.kappa;    % pension share

  % draw initial income‐states
  rng(par.seed)
  pmat0 = pmat^100;                  % “stationary” dist
  y_idx = randsample(par.ylen,NN,true, pmat0(1,:) )';

  % everyone starts at zero assets
  a_idx = ones(NN,1);

  % pre‐allocate T×NN
  csim = nan(T,NN);
  asim = nan(T,NN);
  tsim = nan(T,NN);
  ysim = nan(T,NN);

  % simulate t=1…T
  for t = 1:par.T                % t = 1…T
    age = t-1;                   % age = 0…T-1
    for i = 1:par.NN
      % 1) income today
      if age < par.tr
        ysim(t,i) = par.ygrid(y_idx(i));  
      else
        ysim(t,i) = par.kappa * par.ygrid(y_idx(i));
      end

      % 2) apply the period‐t policy
      csim(t,i) = sol.c(a_idx(i), t, y_idx(i));
      asim(t,i)= sol.a(a_idx(i), t, y_idx(i));

      % 3) update asset‐index for next period
      [~, a_idx(i)] = min(abs(par.agrid - asim(t,i)));

      % 4) if still working, draw next income state
      if age < par.tr-1
        cdf = cumsum(par.pmat(y_idx(i),:));
        y_idx(i) = find(rand<=cdf,1);
      end
    end
  end

  sim.avg_c = mean(csim,2);
  sim.avg_a = mean(asim,2);
  sim.avg_y = mean(ysim,2);
  sim.avg_age = tsim(:,1);    % 0…49
  sim.csim = csim;            % if you still need them
  sim.asim = asim;
  sim.ysim = ysim;
  sim.tsim = tsim;
end

        end
end