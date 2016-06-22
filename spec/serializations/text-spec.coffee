ItemSerializer = require '../../src/item-serializer'
loadOutlineFixture = require '../load-outline-fixture'
Outline = require '../../src/outline'
should = require('chai').should()
Item = require '../../src/item'

fixtureAsTextString = '''
  one
  \ttwo
  \t\tthree
  \t\tfour
  \tfive
  \t\t\tsix
'''

describe 'TEXT Serialization', ->
  [outline, root, one, two, three, four, five, six] = []

  beforeEach ->
    {outline, root, one, two, three, four, five, six} = loadOutlineFixture()
    six.indent = 2

  afterEach ->
    outline.destroy()

  it 'should serialize items to TEXT string', ->
    ItemSerializer.serializeItems(outline.root.descendants, ItemSerializer.TEXTType).should.equal(fixtureAsTextString)

  it 'should deserialize items from TEXT string', ->
    one = ItemSerializer.deserializeItems(fixtureAsTextString, outline, ItemSerializer.TEXTType)[0]
    one.depth.should.equal(1)
    one.bodyString.should.equal('one')
    one.descendants.length.should.equal(5)
    #one.firstChild.firstChild.hasAttribute('data-t').should.be.true
    #one.firstChild.lastChild.hasAttribute('data-t').should.be.true
    one.lastChild.bodyString.should.equal('five')
    #one.lastChild.lastChild.getAttribute('data-t').should.equal('23')
    one.lastChild.lastChild.indent.should.equal(2)
    one.lastChild.lastChild.depth.should.equal(4)

  it 'should convert leading spaces to indentation and serilize using tabs', ->

    # 2 spaces
    serializedItems = '''
      one
         two
          three
          four
        five
            six
    '''
    deserializedOne = ItemSerializer.deserializeItems(serializedItems, outline, ItemSerializer.TEXTType)[0]
    ItemSerializer.serializeItems(Item.flattenItemHiearchy([deserializedOne], false), ItemSerializer.TEXTType).should.equal(fixtureAsTextString)

    # 4 spaces
    serializedItems = '''
      one
          two
              three
              four
          five
                  six
    '''
    deserializedOne = ItemSerializer.deserializeItems(serializedItems, outline, ItemSerializer.TEXTType)[0]
    ItemSerializer.serializeItems(Item.flattenItemHiearchy([deserializedOne], false), ItemSerializer.TEXTType).should.equal(fixtureAsTextString)

    # 8 spaces
    serializedItems = '''
      one
              two
                      three
                      four
              five
                              six
    '''
    deserializedOne = ItemSerializer.deserializeItems(serializedItems, outline, ItemSerializer.TEXTType)[0]
    ItemSerializer.serializeItems(Item.flattenItemHiearchy([deserializedOne], false), ItemSerializer.TEXTType).should.equal(fixtureAsTextString)

  it 'should deserialize empty lines at level of next non empty line', ->
    serializedItems = '''
      one

      \t\tthree
      \t\tfour
      \tfive
      \t\tsix

    '''
    roots = ItemSerializer.deserializeItems(serializedItems, outline, ItemSerializer.TEXTType)
    ItemSerializer.serializeItems(outline.root.descendants, ItemSerializer.TEXTType)

    each = roots[0]
    each.depth.should.equal(1)
    (each = each.nextItem).depth.should.equal(3)
    (each = each.nextItem).depth.should.equal(3)
    (each = each.nextItem).depth.should.equal(3)
    (each = each.nextItem).depth.should.equal(2)
    (each = each.nextItem).depth.should.equal(3)
    roots[1].depth.should.equal(1)

  it 'should deserialize items indented under initial empty line', ->
    serializedItems = '''

      \t\one
    '''
    roots = ItemSerializer.deserializeItems(serializedItems, outline, ItemSerializer.TEXTType)
    roots.length.should.equal(2)
    roots[0].depth.should.equal(2)
    roots[1].depth.should.equal(2)

  it 'should serialize and deserialize overindented items', ->
    item = outline.createItem('one')
    item.indent = 2
    serializedItems = ItemSerializer.serializeItems([item], ItemSerializer.TEXTType, baseDepth: 0)
    serializedItems.should.equal('\t\tone')
    roots = ItemSerializer.deserializeItems(serializedItems, outline, ItemSerializer.TEXTType)
    roots[0].depth.should.equal(3)