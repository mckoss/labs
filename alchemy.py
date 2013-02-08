#!/usr/bin/env python
"""
    A command line version of Alchemy Game.

    Element rules from:
    http://littlealchemy.blogspot.com/
"""
import re

from interact import Interactive


def main():
    game = Alchemy()
    try:
        game.run()
    except KeyboardInterrupt:
        print "Terminated ..."
        game.on_stop()


class Alchemy(Interactive):
    """
    Welcome to Alchemy - command line edition!

    (See also a very cool Chrome Web App at: http://littlealchemy.com/
    on which this program is based.)
    """
    def __init__(self, **kwargs):
        self.inventory = ['earth', 'air', 'fire', 'water']
        self.parse_recipes(ELEMENT_RECIPES)
        super(Alchemy, self).__init__(**kwargs)

    def parse_recipes(self, recipes):
        self.elements = {
            'earth': None,
            'air': None,
            'fire': None,
            'water': None,
            }
        recipes = recipes.split('\n')
        self.elements.update(dict([self.parse_recipe(r) for r in recipes]))

    @staticmethod
    def parse_recipe(s):
        """
        Parse elemental recipe.

        >>> Alchemy.parse_recipe('brick=fire+mud, fire+clay, sun+clay, sun+mud')
        ('brick', [['fire', 'mud'], ['clay', 'fire'], ['clay', 'sun'], ['mud', 'sun']])
        >>> Alchemy.parse_recipe('acid rain=rain+smoke')
        ('acid-rain', [['rain', 'smoke']])
        >>> Alchemy.parse_recipe('corpse=human+gun, grim reaper+human')
        ('corpse', [['gun', 'human'], ['grim-reaper', 'human']])
        """
        parts = s.split('=')
        result = parts[0].replace(' ', '-').lower()
        components = [c.replace(' ', '-').split('+') for c in parts[1].split(', ')]
        for c in components:
            c.sort()
        return (result, components)

    def on_start(self):
        print "You start with 4 elements: %s.  From these" % ', '.join(self.inventory)
        print "you must created the other %d elements." % len(self.elements)

    def help_command(self, *args):
        """ Prints a helpful message. """
        super(Alchemy, self).help_command(*args)
        print "Create new elements by adding two elements in your existing inventory"
        print "together like this:"
        print
        print "    air + water"
        print
        self.inventory_command(*args)

    def inventory_command(self, *args):
        """
        Display the elements you've made, and the ones you can make in a
        single combination.
        """
        print "You have %d of %d total elements.\n" % (len(self.inventory), len(self.elements))
        print "Inventory:"
        self.print_list(self.inventory)

        print "You can make these elements in one step:"
        makeable = self.makeable_from(self.inventory)
        self.print_list(makeable)

    def from_command(self, *args):
        """ Spoiler: this command tells what you can make from the given elements. """
        makeable = self.makeable_from(args[1:])
        print "Makeable:"
        self.print_list(makeable)

    def solve_command(self, *args):
        """
        Spoiler: Display the all the elements, grouped by earliest to latest in makability
        (the later elements require the former for their composition).
        """
        inventory = ['earth', 'air', 'fire', 'water']
        i = 0
        print "Level 0."
        self.print_list(inventory)
        while True:
            next_level = self.makeable_from(inventory)
            if len(next_level) == 0:
                break
            i += 1
            print "Level %d." % i
            self.print_list(next_level)
            inventory.extend(next_level)

        if len(inventory) < len(self.elements):
            print "No recipe for these elements: %s" % \
                ', '.join([e for e in self.elements if e not in inventory])

    def hint_command(self, *args):
        """
        Shows recipe for a given element.

        hint <element> [steps]

        By default shows only the last (1) step in the recipe.
        Use 'all' to show all steps.
        """
        import pdb; pdb.set_trace()
        if len(args) not in (2, 3):
            print "Usage: hint <element> [<number-of-steps> | all]"
            return
        steps = args[2] if len(args) == 3 else 1
        if steps == 'all':
            steps = 999
        else:
            steps = int(steps)
        defined = set()
        all_steps = self.get_steps(args[1], defined)
        print '\n'.join(["%2d. %s" % (index + 1, step)
                         for (index, step) in list(enumerate(all_steps))[-steps:]])

    def get_steps(self, element, defined, show=None):
        steps = []
        if element in defined:
            return steps
        if element not in self.elements:
            print "%s is not an element." % element
            return steps
        combinations = self.elements[element]
        if combinations is None:
            return steps
        ingredients = combinations[0]
        steps.extend(self.get_steps(ingredients[0], defined))
        steps.extend(self.get_steps(ingredients[1], defined))
        defined.add(element)

        combinations = self.elements[element]
        if combinations is None:
            return steps
        ingredients = combinations[0]
        steps.append("%s = %s + %s" % (element, ingredients[0], ingredients[1]))
        return steps

    def makeable_from(self, provided):
        for e in provided:
            if e not in self.elements:
                print "%s is not an element." % e
                return None

        makeable = []
        for (product, combinations) in self.elements.items():
            if combinations is None or product in provided:
                continue
            for c in combinations:
                if all([e in provided for e in c]):
                    makeable.append(product)
                    break
        return makeable

    @staticmethod
    def print_list(strings):
        """
        >>> Alchemy.print_list(['a', 'c', 'b'])
        a, b, c
        <BLANKLINE>
        """
        strings.sort()
        for i in range(len(strings) / 10 + 1):
            print ', '.join(strings[i * 10: (i + 1) * 10])
        print

    def on_unknown(self, *args):
        if len(args) != 3 or args[1] != '+':
            super(Alchemy, self).on_unknown(*args)
            return
        for i in (0, 2):
            if args[i] not in self.elements:
                print "%s is not an element." % args[i]
                return
            if args[i] not in self.inventory:
                print "You don't have %s." % args[i]
                return
        element = self.combine(args[0], args[2])
        if element is None:
            print "I got nothin'."
            return
        if element in self.inventory:
            print "You already have %s." % element
            return
        print "%s + %s make %s!" % (args[0], args[2], element)
        self.inventory.append(element)

    def combine(self, *elements):
        # TODO: I think there are some recipes that produce multiple outputs.
        ingredients = list(elements)
        ingredients.sort()
        for (element, components) in self.elements.items():
            if components is None:
                continue
            for c in components:
                if c == ingredients:
                    return element
        return None


ELEMENT_RECIPES = """acid rain=rain+smoke
airplane=metal+bird, steel+bird
alcohol=time+fruit, juice+time
algae=plant+ocean, plant+water, plant+sea
allergy=dust+human
alligator=swamp+lizard
ambulance=car+hospital, car+doctor
angel=bird+human
Antarctica=desert+ice, desert+snow
aquarium=water+glass, glass+fish
archipelago=isle+isle
armor=metal+tool, steel+tool
ash=energy+volcano
astronaut=human+moon, rocket+human
atmosphere=air+pressure, sky+pressure
atomic bomb=energy+explosion
axe=blade+wood
bacon=fire+pig
bacteria=swamp+life
baker=human+bread, human+flour
barn=house+cow, house+livestock
bat=mouse+bird, sky+mouse
bayonet=blade+gun
beach=water+sand, sand+ocean, sand+sea
beaver=wild animal+wood
beer=alcohol+wheat
bicycle=wheel+wheel
bird=air+egg, sky+egg, sky+life
birdhouse=bird+house
black hole=star+pressure
blade=stone+metal
blizzard=snow+wind, snow+storm
blood=human+blade
boat=water+wood
boiler=metal+steam
bone=time+corpse
bread=fire+dough, fire+flour
brick=fire+mud, fire+clay, sun+clay, sun+mud
bullet=gunpowder+metal
butcher=human+meat
cactus=desert+plant, plant+sand
camel=desert+horse, desert+wild animal
campfire=fire+wood
car=metal+wheel
cart=wood+wheel
castle=knight+house
cat=wild animal+milk
caviar=human+hard roe
centaur=horse+human
cereal=milk+wheat
chainsaw=electricity+axe
charcoal=fire+wood, fire+tree
cheese=time+milk
chicken=bird+livestock
Christmas tree=light bulb+tree
cigarette=paper+tobacco
city=skyscraper+skyscraper, village+village
clay=mud+sand
clock=electricity+time, time+wheel
cloud=air+steam
coal=plant+pressure
coconut=palm+fruit
coconut milk=coconut+tool
coffin=wood+corpse
cold=rain+human
computer=electricity+nerd, nerd+tool
cookie=sugar+dough
corpse=human+gun, grim reaper+human
cow=livestock+grass
cuckoo=clock+bird
cyborg=robot+human
cyclist=human+bicycle
darth vader=jedi+lava
day=sun+time, sun+night
desert=sand+sand
diamond=coal+pressure, coal+time
dinosaur=time+lizard
doctor=hospital+human
dog=wild animal+human
doghouse=dog+house
double rainbow!=rainbow+rainbow
dough=water+flour
dragon=fire+lizard
drunk=alcohol+human, beer+human
duck=water+bird
dune=beach+wind, desert+wind, wind+sand
dust=earth+air, sun+vampire
dynamite=wire+gunpowder
eagle=mountain+bird
earthquake=energy+earth, wave+earth
eclipse=sun+moon
egg=stone+life, bird+bird, lizard+lizard, turtle+turtle
electric eel=electricity+fish
electrician=electricity+human
electricity=energy+metal, sun+solar cell
email=computer+letter
energy=fire+air
engineer=human+tool
eruption=energy+volcano
explosion=fire+gunpowder
family=human+house
farmer=human+field, plant+human
field=earth+tool
fireman=fire+human
fireplace=campfire+house
fireworks=sky+explosion
fish=time+hard roe
flood=rain+time, rain+rain
flour=stone+wheat, windmill+wheat
flute=wind+wood
fog=cloud+earth
forest=tree+tree
fossil=dinosaur+earth, dinosaur+time
Frankenstein=electricity+corpse, electricity+zombie
fruit=tree+farmer, sun+tree
fruit tree=tree+fruit
galaxy=star+star
garden=plant+grass, plant+plant
geyser=earth+steam
glacier=ice+mountain
glass=fire+sand, electricity+sand
glasses=glass+glass, glass+metal
glasshouse=plant+glass
goat=mountain+livestock
golem=life+clay
grass=earth+plant
grave=earth+coffin, earth+corpse
gravestone=stone+grave
graveyard=grave+grave
grenade=explosion+metal
grim reaper=scythe+corpse, scythe+human
gun=metal+bullet
gunpowder=fire+dust
hail=cloud+ice, ice+storm, rain+ice
ham=meat+smoke
hamburger=bread+meat
hard roe=water+egg, egg+ocean, egg+sea, fish+fish
hay=farmer+grass, scythe+grass
hero=dragon+knight
horizon=earth+sky, sky+ocean, sky+sea
horse=hay+livestock
hospital=sickness+house
hourglass=sand+glass
house=brick+tool, human+wood, brick+human, wall+wall
human=earth+life
hurricane=energy+wind
ice=water+cold
ice cream=cold+milk, ice+milk
iceberg=Antarctica+ocean, Antarctica+sea, ice+ocean, ice+sea
idea=light bulb+human
igloo=ice+house
isle=volcano+ocean
jedi=lightsaber+human, knight+lightsaber
juice=water+fruit, pressure+fruit
kite=wind+paper
knight=armor+human
lamp=light bulb+metal
lava=fire+earth
lava lamp=lamp+lava
letter=paper+pencil
life=energy+swamp, time+love
light=electricity+light bulb
light bulb=electricity+glass
lighthouse=light+ocean, light+sea, beach+light, light+house
lightsaber=light+sword, electricity+sword, energy+sword
lion=wild animal+cat
livestock=wild animal+human, life+farmer
lizard=swamp+egg
love=human+human
lumberjack=human+axe
manatee=cow+sea
meat=tool+cow, pig+tool
mermaid=human+fish
metal=fire+stone
meteor=atmosphere+meteoroid
meteoroid=space+stone
milk=human+cow, farmer+cow
mirror=glass+metal
monkey=wild animal+tree
moon=sky+cheese
mountain=earthquake+earth
mouse=wild animal+cheese
mud=water+earth
music=flute+human, sound+human
nerd=glasses+human
nest=hay+bird, tree+bird
newspaper=paper+paper
night=time+moon
oasis=water+desert
ocean=water+sea
oil=sunflower+pressure
omelette=fire+egg
orchard=fruit tree+fruit tree
origami=paper+bird
owl=night+bird
palm=isle+tree
paper=wood+pressure
pegasus=horse+bird, horse+sky
pencil=charcoal+wood, coal+wood
penguin=wild animal+ice, ice+bird
phoenix=fire+bird
pie=dough+fruit
pig=mud+livestock
pilot=airplane+human
pipe=wood+tobacco
pirate=sword+sailor
pizza=cheese+dough
planet=earth+space
plankton=water+life
plant=rain+earth
platypus=beaver+duck
pottery=fire+clay
pressure=earth+earth, air+air
prism=rainbow+glass
rain=water+air, water+cloud
rainbow=sun+rain
ring=diamond+metal
river=water+mountain
robot=metal+life, steel+life
rocket=airplane+space
rust=air+metal
sailboat=wind+boat
sailor=sailboat+human, human+boat
salt=sun+ocean, sun+sea
sand=stone+air
sandpaper=paper+sand
sandstorm=hurricane+sand, energy+sand, storm+sand
sandwich=cheese+bread, bread+ham
scissors=blade+blade
scythe=blade+grass, blade+wheat
sea=water+water
seagull=beach+bird, bird+ocean, bird+sea
seahorse=horse+ocean, horse+sea
seasickness=sickness+ocean, sickness+sea
seaweed=plant+ocean, plant+sea
shark=blood+ocean, blood+sea, wild animal+ocean, wild animal+sea
sheep=cloud+livestock
sickness=rain+human, sickness+human
ski goggles=snow+glasses
sky=cloud+air
skyscraper=sky+house
smog=fog+smoke
smoke=fire+wood
snake=wire+wild animal
snow=rain+cold
snowman=snow+human
solar cell=sun+tool
sound=wave+air
space=star+moon, star+sky, sun+star
squirrel=mouse+tree
star=night+sky
starfish=star+fish, star+ocean, star+sea
statue=stone+tool
steam=water+fire, water+energy
steam engine=boiler+tool
steamboat=steam engine+boat, water+steam engine
steel=coal+metal
stone=air+lava
storm=electricity+cloud, energy+cloud
story=human+campfire
sugar=fire+juice, energy+fruit, energy+juice
sun=fire+sky
sundial=sun+clock
sunflower=sun+plant
sunglasses=sun+glasses
surfer=wave+human
sushi=seaweed+caviar, seaweed+fish
swamp=mud+plant
swim goggles=water+glasses
sword=metal+blade, steel+blade
swordfish=sword+fish
telescope=star+glass, sky+glass
tide=moon+ocean, moon+sea
time=sand+glass
toast=fire+bread, fire+sandwich
tobacco=fire+plant
tool=metal+human
train=metal+steam engine, steel+steam engine
tree=plant+time
treehouse=tree+house
tsunami=earthquake+ocean
turtle=sand+egg
twilight=day+night
unicorn=double rainbow!+horse, double rainbow!+life, rainbow+horse, rainbow+life
vampire=blood+human, vampire+human
village=house+house
volcano=earth+lava
vulture=bird+corpse
wagon=horse+cart
wall=brick+brick
warrior=sword+human
watch=clock+human
water pipe=water+pipe
wave=wind+ocean, wind+sea
werewolf=wolf+human, werewolf+human
wheat=field+farmer
wheel=tool+wood
wild animal=life+forest
wind=air+pressure
windmill=wind+house, wind+wheel
wine=alcohol+fruit
wire=electricity+metal
wolf=dog+forest, wild animal+dog, wild animal+moon
wood=tree+tool
yogurt=bacteria+milk
zombie=life+corpse, human+zombie
alien=life+space
avalanche=energy+snow
batman=bat+human
book=story+paper
dam=river+wall
faun=goat+human
internet=computer+computer, wire+computer
leather=blade+cow
motorcycle=energy+bicycle
wizard=energy+human
butter=pressure+milk
egg timer=clock+egg
gold=sun+metal
moss=algae+stone
oxygen=sun+plant
pond=water+garden
pyramid=desert+grave
sandcastle=sand+castle
umbrella=rain+tool
yoda=jedi+swamp
bridge=steel+river, metal+river, wood+river
broom=hay+wood
candy cane=sugar+christmas tree
carbon dioxide=human+oxygen, plant+night
chimney=house+fireplace
christmas stocking=wool+fireplace
fridge=cold+metal, cold+electricity
gift=santa+christmas tree, santa+chimney, fireplace+santa, santa+christmas  stocking,  santa+cookies
king=human+castle
leaf=tree+wind
printer=paper+computer
reindeer=wild animal+santa
santa=human+christmas tree
scarecrow=human+hay
scorpion=wild animal+sand, wild animal+dune
sledge=snow+wagon, snow+cart
snowball=snow+human
snowboard=snow+wood
sweater=wool+tool
wool=sheep+tool"""


if __name__ == '__main__':
    main()
