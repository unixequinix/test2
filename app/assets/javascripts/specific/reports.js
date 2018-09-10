function lineChart(labels, datasets, customLabel) {
  new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: Object.keys(datasets).map(function(key) { return datasets[key] })
    },
    options: {
      scales: {
        yAxes: [{
          ticks: {
            beginAtZero: true
          }
        }]
      },
      legend: {
        position: 'right'
      },
      tooltips: {
        custom: function(tooltip) {
          if (!tooltip) return;
          tooltip.displayColors = false;
        },
        callbacks: {
          title: function(tooltipItem, data) {
            var titleData = tooltipItem[0];
            var key = Object.keys(datasets)[titleData.datasetIndex];

            return [
              key.charAt(0).toUpperCase() + key.slice(1),
              titleData.xLabel
            ]
          },
          label: function(tooltipItem, data) {
            var key = Object.keys(datasets)[tooltipItem.datasetIndex];
            return [key.humanize() + ": " + datasets[key]['data'][tooltipItem.index] + customLabel]
          }
        }
      }
    }
  })
};

function doughnutChart(labels, datasets) {
  new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: Object.keys(datasets).map(function(key) { return datasets[key] })
    },
    options: {
      legend: {
        position: 'right'
      },
      tooltips: {
        custom: function (tooltip) {
          if (!tooltip) return;
          tooltip.displayColors = false;
        },
        callbacks: {
          title: function (tooltipItem, data) {
            return [data.labels[tooltipItem[0].index]]
          },
          label: function (tooltipItem, data) {
            var key = Object.keys(datasets)[tooltipItem.datasetIndex];
            return [datasets[key].label.humanize() + ": " + data.datasets[0].data[tooltipItem.index]]
          }
        }
      }
    }
  })
};


function gradientSector(ctx, colors) {
  var gradient = ctx.createLinearGradient(0, 200, 100, 20);

  gradient.addColorStop(0, colors[0]);
  gradient.addColorStop(1, colors[1]);

  return gradient
}

String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.humanize = function() {
  return this.replace(/[_\s]+/g, ' ').capitalize().decamelize();
};

String.prototype.decamelize = function() {
  return this.split(/\s*(?=[A-Z])/).join(' ')
};
