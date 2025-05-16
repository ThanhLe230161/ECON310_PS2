%––– Parameter ranges –––%
gammaVals = [2.00, 3.00, 4.00, 5.00];
betaVals  = [0.90, 0.92, 0.94, 0.96];
nG = numel(gammaVals);
nB = numel(betaVals);

%––– Pre‐allocate –––%
avgWealth = nan(nB, nG);

%––– Compute average wealth for each (β,γ) –––%
par0 = model_2.setup();
for iB = 1:nB
  for jG = 1:nG
    par        = par0;
    par.beta   = betaVals(iB);
    par.sigma  = gammaVals(jG);
    par        = model_2.gen_grids(par);
    sol        = solve_2.lc(par);
    sim        = simulate_2.lc(par,sol);
    % economy‐wide average wealth (over agents × ages)
    avgWealth(iB,jG) = mean(sim.asim, 'all');
  end
end

%––– Plot heat‐map –––%
figure('Color','w','Position',[200 200 600 400]);
%––– make the chart –––%
h = heatmap(gammaVals, betaVals, avgWealth);

%––– now style it –––%
h.Colormap        = parula(256);        % actual M×3 array of RGB’s
h.ColorbarVisible = 'on';               % turn on the colorbar

%––– any other cosmetics –––%
h.Title = '\bf Average Wealth by (\gamma,\beta)';
h.XLabel = '\gamma';
h.YLabel = '\beta';