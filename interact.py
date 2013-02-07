import re

reg_line = re.compile(r'[a-zA-Z09_\-\.]+|\+|\-|\*|\\|\?')
SUFFIX = '_command'


class Interactive(object):
    def __init__(self, prompt=None):
        self.prompt = prompt or self.__class__.__name__ + '> '

    def run(self):
        print self.__doc__

        self.on_start()

        print "\nCommands: %s" % ', '.join(self.get_commands())

        while True:
            s = raw_input(self.prompt)
            parts = reg_line.findall(s)
            if len(parts) == 0:
                continue
            if parts[0] == '?':
                parts[0] = 'help'
            func = getattr(self, parts[0] + SUFFIX, self.on_unknown)
            try:
                func(*parts)
            except Exception, e:
                print "Error: %s" % str(e)

    def on_unknown(self, *args):
        print "Unknown command: '%s'" % args[0]

    def quit_command(self, *args):
        """ Exit this interactive session. """
        self.on_stop()
        exit(1)

    def on_start(self):
        pass

    def on_stop(self):
        pass

    def get_commands(self):
        return [attr[:-len(SUFFIX)] for attr in dir(self) if attr.endswith(SUFFIX)]

    def help_command(self, *args):
        """ Print this help message. """
        for cmd in self.get_commands():
            doc = getattr(self, cmd + SUFFIX).__doc__
            if doc is None:
                doc = "(undocumented)"
            else:
                doc = doc.strip()
            print "    %s: %s" % (cmd, doc)
