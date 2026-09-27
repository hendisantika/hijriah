// css
import 'admin-lte/dist/css/adminlte.min.css';
import '@fortawesome/fontawesome-free/css/all.min.css';
import 'icheck-bootstrap/icheck-bootstrap.min.css';
import 'select2/dist/css/select2.min.css';
import '@ttskch/select2-bootstrap4-theme/dist/select2-bootstrap4.min.css';
import 'overlayscrollbars/styles/overlayscrollbars.css';


// script
import 'expose-loader?$!expose-loader?jQuery!jquery';
import 'bootstrap';
import 'admin-lte';
import 'select2/dist/js/select2.full.min.js';

// momentjs
import moment from 'moment';
import 'moment/locale/id';

moment.locale('id');
window.moment = moment;

sanitizeUrlParam();
swUpdate();



async function swUpdate() {
    const workbox = await window.$workbox;
    if (workbox) {
        workbox.addEventListener('installed', (event) => {
            if (event.isUpdate) {
                window.location.reload();
            }
        });
    }
}

function sanitizeUrlParam() {
    const { origin, search, pathname, hash } = window.location;
    const allowedParams = [];
    if (search) {
        const searchParams = new URLSearchParams(search);
        searchParams.forEach((v, k) => {
            if (allowedParams.indexOf(k) == -1) {
                searchParams.delete(k);
            }
        });
        let q = searchParams.toString();
        let url = `${origin}${pathname}${q ? '?' + q : ''}${hash}`;
        window.location.replace(url);
    }
}
