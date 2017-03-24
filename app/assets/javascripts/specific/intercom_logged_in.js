var APP_ID = 'lqjg9vd4';

window.intercomSettings = {
    app_id: APP_ID,
    name: current_user_name, // Full name
    email: current_user_email, // Email address
    user_id: current_user_id // current_user_id
};

(function() {
    var d, i, ic, l, w;
    w = window;
    ic = w.Intercom;
    l = function() {
        var s, x;
        s = d.createElement('script');
        s.type = 'text/javascript';
        s.async = true;
        s.src = 'https://widget.intercom.io/widget/' + APP_ID;
        x = d.getElementsByTagName('script')[0];
        x.parentNode.insertBefore(s, x);
    };
    if (typeof ic === 'function') {
        ic('reattach_activator');
        ic('update', intercomSettings);
    } else {
        d = document;
        i = function() {
            i.c(arguments);
        };
        i.q = [];
        i.c = function(args) {
            i.q.push(args);
        };
        w.Intercom = i;
        if (w.attachEvent) {
            w.attachEvent('onload', l);
        } else {
            w.addEventListener('load', l, false);
        }
    }
})();