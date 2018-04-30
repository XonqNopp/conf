iabbrev <buffer> F_N <C-R>=expand("%:t:r")<cr>
iabbrev <buffer> fiG figure'name',['#&%']);<cr>set(gca,'fontsize',16);<cr>hold('on');<cr>plot(#&%);<cr>xlabel('#&%');<cr>ylabel('#&%');<cr>%legend(#&%,'location','best');<cr>%print('-dpsc2',[#&%.ps']);<cr><esc>?figure<cr>ea
