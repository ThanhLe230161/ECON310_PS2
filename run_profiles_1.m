% Pre‐compute
par0       = model_2.setup();
T         = par0.T;          % e.g. 50
betaVals   = [0.90,0.92,0.94,0.96];
nBeta      = numel(betaVals);
G    = par0.G; 

C_profiles = nan(T,nBeta);
A_profiles = nan(T,nBeta);

for j = 1:nBeta
  par      = par0;
  par.beta = betaVals(j);
  par.gamma= 2.00;
  par      = model_2.gen_grids(par);

  sol      = solve_2.lc(par);
  sim      = simulate_2.lc(par,sol);

  C_profiles(:,j) = sim.avg_c./sim.avg_y;
  A_profiles(:,j) = sim.avg_a;
end

% Plot
ages = 0:(T-1);
figure('Color','w','Position',[200 200 800 500]); hold on;
cols = lines(nBeta);

for j = 1:nBeta
  plot(ages, C_profiles(:,j), '-',  'Color',cols(j,:),'LineWidth',1.8);
  plot(ages, A_profiles(:,j), '--', 'Color',cols(j,:),'LineWidth',1.8);
end
hold off;
grid on; box on;
xlim([0 T-1]);
xlabel('Age','FontSize',14,'FontWeight','bold');
ylabel('Level','FontSize',14,'FontWeight','bold');
title('\bf Life‐Cycle Profiles (\gamma=2.00)','FontSize',16);
legend(reshape([ ...
  compose("C, \\beta=%.2f",betaVals);
  compose("A, \\beta=%.2f",betaVals) ]',1,[]), ...
  'Location','northeastoutside');
