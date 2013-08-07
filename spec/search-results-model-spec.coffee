RootView = require 'root-view'
SearchModel = require 'search-in-buffer/lib/search-model'
SearchResultsModel = require 'search-in-buffer/lib/search-results-model'

fdescribe 'SearchResultsModel', ->
  [goToLine, editor, subject, buffer, searchModel] = []

  beforeEach ->
    window.rootView = new RootView
    rootView.open('sample.js')
    rootView.enableKeymap()
    editor = rootView.getActiveView()
    buffer = editor.activeEditSession.buffer

    searchModel = new SearchModel()
    subject = new SearchResultsModel(searchModel, editor)

  describe "search()", ->
    beforeEach ->
      subject.setBuffer(buffer)
      searchModel.setPattern('items')

    it "finds all the matching ranges", ->
      expect(subject.markers.length).toEqual 6

  describe "findNext()", ->
    beforeEach ->
      subject.setBuffer(buffer)
      searchModel.setPattern('items')

    it "finds next when before all ranges", ->
      marker = subject.findNext([[0,0],[0,3]])
      expect(marker.getRange()).toEqual [[1,22],[1,27]]

    it "finds next when between ranges", ->
      marker = subject.findNext([[2,22],[2,23]])
      expect(marker.getRange()).toEqual [[2,34],[2,39]]

    it "wraps when after all ranges", ->
      marker = subject.findNext([[12,0],[12,0]])
      expect(marker.getRange()).toEqual [[1,22],[1,27]]

    it "finds proper next range when selection == range", ->
      marker = subject.findNext([[1,22],[1,27]])
      expect(marker.getRange()).toEqual [[2,8],[2,13]]

    it "finds proper next range when selection inside of range", ->
      marker = subject.findNext([[1,22],[1,25]])
      expect(marker.getRange()).toEqual [[2,8],[2,13]]

    it "handles update to buffer", ->
      buffer.on 'contents-modified', changeHandler = jasmine.createSpy()
      buffer.insert([1, 0], "xxx")

      advanceClock(buffer.stoppedChangingDelay+2)

      marker = subject.findNext([[0,0],[0,3]])
      expect(marker.getRange()).toEqual [[1,25],[1,30]]