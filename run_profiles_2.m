% Pre‐compute
par0       = model_2.setup();
T          = par0.T;           % e.g. 50
gammaVals  = [2.00, 3.00, 4.00, 5.00];
nGamma     = numel(gammaVals);

C_profiles = nan(T,nGamma);
A_profiles = nan(T,nGamma);

for j = 1:nGamma

  par       = par0;
  par.sigma = gammaVals(j);    % <-- pass the CRRA exponent into your model
  par.beta  = 0.96;
  par       = model_2.gen_grids(par);

  sol       = solve_2.lc(par);
  sim       = simulate_2.lc(par,sol);

  C_profiles(:,j) = sim.avg_c ./ sim.avg_y;
  A_profiles(:,j) = sim.avg_a;

end

% Plot
ages = 0:(T-1);
figure('Color','w','Position',[200 200 800 500]); 
hold on;
cols = lines(nGamma);

for j = 1:nGamma    % <-- loop over gamma, not beta
  plot(ages, C_profiles(:,j), '-',  'Color',cols(j,:), 'LineWidth',1.8);
  plot(ages, A_profiles(:,j), '--', 'Color',cols(j,:), 'LineWidth',1.8);
end
hold off;

grid on; box on;
xlim([0 T-1]);
xlabel('Age','FontSize',14,'FontWeight','bold');
ylabel('Level','FontSize',14,'FontWeight','bold');
title('\bf Life‐Cycle Profiles (\beta=0.96)','FontSize',16);

% Build a legend that shows gamma
leg = strings(1,2*nGamma);
for j = 1:nGamma
  leg(2*j-1) = sprintf('C, \\gamma=%.2f', gammaVals(j));
  leg(2*j  ) = sprintf('A, \\gamma=%.2f', gammaVals(j));
end
legend(leg,'Location','northeastoutside','FontSize',10);
