'use strict';
(function () {
    var Widget = function (id) {
        var oldFrameScr;
        var oldHeight;
        var getIframeElement = function () {
            var iFrame = document.getElementById(id);
            return iFrame;
        };
        var parseParameter = function (attribute) {
            return JSON.parse(attribute.replace(/'/g, '"'));
        };
        var getFrameSrc = function () {
            var appletScript = document.getElementById('widget');
            var dataApplication = appletScript.getAttribute('data-application');
            return '../WIDGET/index.html?application=' + dataApplication;
        };
        var getFrameBodyHeight = function () {
            var iFrame = getIframeElement();
            if (iFrame) {
                var body = iFrame.contentDocument.getElementsByTagName('body')[0];
                var html = iFrame.contentDocument.getElementsByTagName('html')[0];
                body.style.overflow = 'hidden';
                return Math.max( body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight );
            } else {
                return 0;
            }
        };
        this.draw = function () {
            var oldFrame = getIframeElement();
            if (oldFrame) {
                oldFrame.parentNode.removeChild(oldFrame);
            }
            var iFrame = document.createElement('IFRAME');
            iFrame.setAttribute('id', id);
            iFrame.setAttribute('src', getFrameSrc());
            iFrame.style.zIndex = 999;
            iFrame.style.width = 400 + 'px';
            iFrame.style.height = 0 + 'px';
            iFrame.style.position = 'absolute';
            iFrame.style.top = '0px';
            iFrame.style.right = '10px';
            iFrame.style.overflow = 'hidden';
            iFrame.style.border = '0px';
            document.body.appendChild(iFrame);
        };
        this.resize = function () {
            var iFrame = getIframeElement();
            if (iFrame) {
                iFrame.style.height = getFrameBodyHeight() + 'px';
            }
        };
        setInterval((function () {
            if (this.onContextChange && oldFrameScr !== getFrameSrc()) {
                oldFrameScr = getFrameSrc();
                this.onContextChange();
            }
            if (this.onSizeChange && oldHeight !== getFrameBodyHeight()) {
                oldHeight = getFrameBodyHeight();
                this.onSizeChange();
            }
        }).bind(this), 1000);
    };
    var widget = new Widget('widget-container');
    widget.onSizeChange = function () {
        this.resize();
    };
    widget.onContextChange = function () {
        this.draw();
    };
})();