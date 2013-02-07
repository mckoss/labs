#!/usr/bin/env python
"""
    A command line version of Alchemy Game.

    Element rules from:
    http://littlealchemy.blogspot.com/
"""
import re

SUFFIX = '_command'


def main():
    game = Alchemy()
    try:
        game.run()
    except KeyboardInterrupt:
        print "Terminated ..."
        game.on_stop()


reg_line = re.compile(r'[a-zA-Z09_\-\.]+|\+|\-|\*|\\|\?')


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
            func(*parts)

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


class Alchemy(Interactive):
    """
    Welcome to Alchemy - Command Line Edition.

    See also a very cool Chrome Web App at: http://littlealchemy.com/

    """
    def __init__(self, **kwargs):
        self.inventory = ['earth', 'air', 'fire', 'water']
        super(Alchemy, self).__init__(**kwargs)

    def on_start(self):
        print "You start with 4 elements: %s.  From these" % ', '.join(self.inventory)
        print "you must created the other %d elements." % (len(elements) - 4)

    def inventory_command(self, *args):
        print "You have %s." % ', '.join(self.inventory)

    def on_unknown(self, *args):
        if len(args) != 3 or args[1] != '+':
            super(Alchemy, self).on_unknown(*args)
            return
        for i in (0, 2):
            args[i] = args[i].lower()
            if args[i] not in elements:
                print "%s is not an element." % args[i]
                return
            if args[i] not in self.inventory:
                print "You don't have %s." % args[i]
        element = self.combine(args[0], args[2])
        if element is None:
            print "Nothing happens."
        self.inventory.append(element)
        print "%s + %s make %s!" % (args[0], args[2], element)

    def combine(self, *elements):
        pass


elements = {
    'earth': None,
    'air': None,
    'fire': None,
    'water': None,
    'pressure': [['air', 'air']],
    }


"""
Basic Elements
1.             water
2.            fire
3.            earth
4.            air

Combinations
5.            acid rain=rain+smoke
6.            airplane=metal+bird, steel+bird
7.            alcohol=time+fruit, juice+time
8.            algae=plant+ocean, plant+water, plant+sea
9.            allergy=dust+human
10.        alligator=swamp+lizard
11.         ambulance=car+hospital, car+doctor
12.         angel=bird+human
13.         Antarctica =desert+ice, desert+snow
14.        aquarium=water+glass, glass+fish
15.         archipelago=isle+isle
16.         armor=metal+tool, steel+tool
17.         ash=energy+volcano
18.         astronaut=human+moon, rocket+human
19.         atmosphere=air+pressure, sky+pressure
20.        atomic bomb=energy+explosion
21.         axe=blade+wood

22.        bacon=fire+pig
23.        bacteria=swamp+life
24.        baker=human+bread, human+flour
25.        barn=house+cow, house+livestock
26.        bat=mouse+bird, sky+mouse
27.        bayonet=blade+gun
28.        beach=water+sand, sand+ocean, sand+sea
29.        beaver=wild animal+wood
30.        beer=alcohol+wheat
31.         bicycle=wheel+wheel
32.        bird=air+egg, sky+egg, sky+life
33.        birdhouse=bird+house
34.        black hole=star+pressure
35.        blade=stone+metal
36.        blizzard=snow+wind, snow+storm
37.        blood=human+blade
38.        boat=water+wood
39.        boiler=metal+steam
40.       bone=time+corpse
41.        bread=fire+dough, fire+flour
42.        brick=fire+mud, fire+clay, sun+clay, sun+mud
43.        bullet=gun powder+metal
44.       butcher=human+meat

45.        cactus=desert+plant, plant+sand
46.        camel=desert+horse, desert+wild animal
47.        campfire=fire+wood
48.        car=metal+wheel
49.        cart=wood+wheel
50.        castle=knight+house
51.         cat=wild animal+milk
52.        caviar=human+hard roe
53.        centaur=horse+human
54.        cereal=milk+wheat
55.        chainsaw=electricity+axe
56.        charcoal=fire+wood, fire+tree
57.        cheese=time+milk
58.        chicken=bird+livestock
59.        Christmas tree=light bulb+tree
60.        cigarette=paper+tobacco
61.         city=skyscraper+skyscraper, village+village
62.        clay=mud+sand
63.        clock=electricity+time, time+wheel
64.        cloud=air+steam
65.        coal=plant+pressure
66.        coconut=palm+fruit
67.        coconut milk=coconut+tool
68.        coffin=wood+corpse
69.        cold=rain+human
70.        computer=electricity+nerd, nerd+tool
71.         cookie=sugar+dough
72.        corpse=human+gun, grim reaper+human
73.        cow=livestock+grass
74.        cuckoo=clock+bird
75.        cyborg=robot+human
76.        cyclist=human+bicycle

77.        darth vader=jedi+lava
78.        day=sun+time, sun+night
79.        desert=sand+sand
80.        diamond=coal+pressure, coal+time
81.         dinosaur=time+lizard
82.        doctor=hospital+human
83.        dog=wild animal+human
84.        doghouse=dog+house
85.        double rainbow!=rainbow+rainbow
86.        dough=water+flour
87.        dragon=fire+lizard
88.        drunk=alcohol+human, beer+human
89.        duck=water+bird
90.        dune=beach+wind, desert+wind, wind+sand
91.         dust=earth+air, sun+vampire
92.        dynamite=wire+gunpowder

93.        eagle=mountain+bird
94.        earthquake=energy+earth, wave+earth
95.        eclipse=sun+moon
96.        egg=stone+life, bird+bird, lizard+lizard, turtle+turtle
97.        electric eel=electricity+fish
98.        electrician=electricity+human
99.        electricity=energy+metal, sun+solar cell
100.    email=computer+letter
101.     energy=fire+air
102.    engineer=human+tool
103.    eruption=energy+volcano
104.    explosion=fire+gunpowder

105.    family=human+house
106.    farmer=human+field, plant+human
107.    field=earth+tool
108.    fireman=fire+human
109.    fireplace=campfire+house
110.     fireworks=sky+explosion
111.      fish=time+hard roe
112.     flood=rain+time, rain+rain
113.     flour=stone+wheat, windmill+wheat
114.     flute=wind+wood
115.     fog=cloud+earth
116.     forest=tree+tree
117.     fossil=dinosaur+earth, dinosaur+time
118.     Frankenstein=electricity+corpse, electricity+zombie
119.     fruit=tree+farmer, sun+tree
120.    fruit tree=tree+fruit

121.     galaxy=star+star
122.     garden=plant+grass, plant+plant
123.     geyser=earth+steam
124.    glacier=ice+mountain
125.     glass=fire+sand, electricity+sand
126.     glasses=glass+glass, glass+metal
127.     glasshouse=plant+glass
128.     goat=mountain+livestock
129.     golem=life+clay
130.    grass=earth+plant
131.     grave=earth+coffin, earth+corpse
132.     gravestone=stone+grave
133.     graveyard=grave+grave
134.    grenade=explosion+metal
135.     grim reaper=scythe+corpse, scythe+human
136.     gun=metal+bullet
137.     gunpowder=fire+dust

138.     hail=cloud+ice, ice+storm, rain+ice
139.     ham=meat+smoke
140.    hamburger=bread+meat
141.     hard roe=water+egg, egg+ocean, egg+sea, fish+fish
142.    hay=farmer+grass, scythe+grass
143.    hero=dragon+knight
144.    horizon=earth+sky, sky+ocean, sky+sea
145.    horse=hay+livestock
146.    hospital=sickness+house
147.    hourglass=sand+glass
148.    house=brick+tool, human+wood, brick+human, wall+wall
149.    human=earth+life
150.    hurricane=energy+wind

151.     ice=water+cold
152.     ice cream=cold+milk, ice+milk
153.     iceberg=Antarctica+ocean, Antarctica+sea, ice+ocean, ice+sea
154.    idea=light bulb+human
155.     igloo=ice+house
156.     isle=volcano+ocean

157.     jedi=lightsaber+human, knight+lightsaber
158.     juice=water+fruit, pressure+fruit

159.     kite=wind+paper
160.    knight=armor+human

161.     lamp=light bulb+metal
162.     lava=fire+earth
163.     lava lamp=lamp+lava
164.    letter=paper+pencil
165.     life=energy+swamp, time+love
166.     light=electricity+light bulb
167.     light bulb=electricity+glass
168.     lighthouse=light+ocean, light+sea, beach+light, light+house
169.     lightsaber=light+sword, electricity+sword, energy+sword
170.    lion=wild animal+cat
171.     livestock=wild animal+human, life+farmer
172.     lizard=swamp+egg
173.     love=human+human
174.    lumberjack=human+axe

175.     manatee=cow+sea
176.     meat=tool+cow, pig+tool
177.     mermaid=human+fish
178.     metal=fire+stone
179.     meteor=atmosphere+meteoroid
180.    meteoroid=space+stone
181.     milk=human+cow, farmer+cow
182.     mirror=glass+metal
183.     monkey=wild animal+tree
184.    moon=sky+cheese
185.     mountain=earthquake+earth
186.     mouse=wild animal+cheese
187.     mud=water+earth
188.     music=flute+human, sound+human

189.     nerd=glasses+human
190.    nest=hay+bird, tree+bird
191.     newspaper=paper+paper
192.     night=time+moon

193.     oasis=water+desert
194.    ocean=water+sea
195.     oil=sunflower+pressure
196.     omelette=fire+egg
197.     orchard=fruit tree+fruit tree
198.     origami=paper+bird
199.     owl=night+bird

200.   palm=isle+tree
201.    paper=wood+pressure
202.    pegasus=horse+bird, horse+sky
203.    pencil=charcoal+wood, coal+wood
204.   penguin=wild animal+ice, ice+bird
205.    phoenix=fire+bird
206.    pie=dough+fruit
207.    pig=mud+livestock
208.    pilot=airplane+human
209.    pipe=wood+tobacco
210.    pirate=sword+sailor
211.     pizza=cheese+dough
212.     planet=earth+space
213.     plankton=water+life
214.    plant=rain+earth
215.     platypus=beaver+duck
216.     pottery=fire+clay
217.     pressure=earth+earth, air+air
218.     prism=rainbow+glass

219.     rain=water+air, water+cloud
220.    rainbow=sun+rain
221.     ring=diamond+metal
222.    river=water+mountain
223.    robot=metal+life, steel+life
224.    rocket=airplane+space
225.    rust=air+metal

226.    sailboat=wind+boat
227.    sailor=sailboat+human, human+boat
228.    salt=sun+ocean, sun+sea
229.    sand=stone+air
230.    sandpaper=paper+sand
231.     sandstorm=hurricane+sand, energy+sand, storm+sand
232.    sandwich=cheese+bread, bread+ham
233.    scissors=blade+blade
234.    scythe=blade+grass, blade+wheat
235.    sea=water+water
236.    seagull=beach+bird, bird+ocean, bird+sea
237.    seahorse=horse+ocean, horse+sea
238.    seasickness=sickness+ocean, sickness+sea
239.    seaweed=plant+ocean, plant+sea
240.   shark=blood+ocean, blood+sea, wild animal+ocean, wild animal+sea
241.    sheep=cloud+livestock
242.    sickness=rain+human, sickness+human
243.    ski goggles=snow+glasses
244.   sky=cloud+air
245.    skyscraper=sky+house
246.    smog=fog+smoke
247.    smoke=fire+wood
248.    snake=wire+wild animal
249.    snow=rain+cold
250.    snowman=snow+human
251.     solar cell=sun+tool
252.    sound=wave+air
253.    space=star+moon, star+sky, sun+star
254.    squirrel=mouse+tree
255.    star=night+sky
256.    starfish=star+fish, star+ocean, star+sea
257.    statue=stone+tool
258.    steam=water+fire, water+energy
259.    steam engine=boiler+tool
260.    steamboat=steam engine+boat, water+steam engine
261.     steel=coal+metal
262.    stone=air+lava
263.    storm=electricity+cloud, energy+cloud
264.    story=human+campfire
265.    sugar=fire+juice, energy+fruit, energy+juice
266.    sun=fire+sky
267.    sundial=sun+clock
268.    sunflower=sun+plant
269.    sunglasses=sun+glasses
270.    surfer=wave+human
271.     sushi=seaweed+caviar, seaweed+fish
272.    swamp=mud+plant
273.    swim goggles=water+glasses
274.    sword=metal+blade, steel+blade
275.    swordfish=sword+fish

276.    telescope=star+glass, sky+glass
277.    tide=moon+ocean, moon+sea
278.    time=sand+glass
279.    toast=fire+bread, fire+sandwich
280.    tobacco=fire+plant
281.     tool=metal+human
282.    train=metal+steam engine, steel+steam engine
283.    tree=plant+time
284.    treehouse=tree+house
285.    tsunami=earthquake+ocean
286.    turtle=sand+egg
287.    twilight=day+night

288.    unicorn=double rainbow!+horse, double rainbow!+life, rainbow+horse, rainbow+life

289.    vampire=blood+human, vampire+human
290.    village=house+house
291.     volcano=earth+lava
292.    vulture=bird+corpse

293.    wagon=horse+cart
294.    wall=brick+brick
295.    warrior=sword+human
296.    watch=clock+human
297.    water pipe=water+pipe
298.    wave=wind+ocean, wind+sea
299.    werewolf=wolf+human, werewolf+human
300.   wheat=field+farmer
301.    wheel=tool+wood
302.    wild animal=life+forest
303.    wind=air+pressure
304.   windmill=wind+house, wind+wheel
305.    wine=alcohol+fruit
306.    wire=electricity+metal
307.    wolf=dog+forest, wild animal+dog, wild animal+moon
308.    wood=tree+tool

309.    yogurt=bacteria+milk

310.    zombie=life+corpse, human+zombie
"""

if __name__ == '__main__':
    main()
