"""
  deferred.py - Inspired by Promises/A
  http://wiki.commonjs.org/wiki/Promises/A
"""


class Deferred(object):
    def __init__(self):
        self.finished = False
        self.is_resolved = False
        self.resolved_callbacks = []
        self.error_callbacks = []
        self.always_callbacks = []
        self.args = []
        self.kwargs = {}
        self.after = None

    def then(self, callback=None, error=None, always=None):
        if self.after is None:
            self.after = Deferred()

        if not self.finished:
            if callback is not None:
                self.resolved_callbacks.append(callback)
            if error is not None:
                self.error_callbacks.append(error)
            if always is not None:
                self.always_callbacks.append(always)
            return self.after

        then_value = None
        if self.is_resolved:
            if callback is not None:
                try:
                    then_value = callback(*self.args, **self.kwargs)
                except:
                    pass
        else:
            if error is not None:
                try:
                    then_value = error(*self.args, **self.kwargs)
                except:
                    pass

        if always is not None:
            try:
                value = always(*self.args, **self.kwargs)
                if then_value is None:
                    then_value = value
            except:
                pass

        if not self.after.finished:
            self.after.resolve(then_value)

        return self.after

    def resolve(self, *args, **kwargs):
        if self.finished:
            raise DeferredError("Deferred is already finished.")

        self.finished = True
        self.is_resolved = True
        self.args = args
        self.kwargs = kwargs
        self._do_calls('resolved')
        self._do_calls('always')

    def reject(self, *args, **kwargs):
        if self.finished:
            raise DeferredError("Deferred is already finished.")

        self.finished = True
        self.args = args
        self.kwargs = kwargs
        self._do_calls('error')
        self._do_calls('always')

    def _do_calls(self, name):
        callbacks = getattr(self, name + '_callbacks')
        then_value = None
        for callback in callbacks:
            try:
                value = callback(*self.args, **self.kwargs)
                if then_value is None:
                    then_value = value
            except:
                pass
        setattr(self, name + '_callbacks', None)
        if self.after is not None and not self.after.finished:
            self.after.resolve(then_value)


class When(Deferred):
    """ Deferred that resolves iff all it's pre-requisite Deferred's are resolved. """
    def __init__(self, *prereqs):
        super(When, self).__init__()
        self.prereqs = prereqs
        self.satisfied = 0
        for deferred in prereqs:
            if deferred.is_resolved:
                self.satisfied += 1
            deferred.then(self.on_resolved, error=self.on_error)

    def on_resolved(self, *args, **kwargs):
        self.satisfied += 1
        if self.satisfied == len(self.prereqs):
            self.resolve()

    def on_error(self, *args, **kwargs):
        self.reject(*args, **kwargs)


class DeferredError(Exception):
    pass
