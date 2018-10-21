import * as Types from '../constants/ActionTypes'

import * as designs from '../reducers/designs'
import * as sorting from '../reducers/designs/sorting'
import * as selection from '../reducers/designs/selection'
import * as pagination from '../reducers/designs/pagination'

export const loadDesigns = () => ({
  type: Types.DESIGNS_LOAD
})

export const loadDesignsSuccess = (designs, timestamp) => ({
  type: Types.DESIGNS_LOAD_SUCCESS, designs, timestamp
})

export const loadDesignsFailure = (error) => ({
  type: Types.DESIGNS_LOAD_FAILURE, error
})

export const showCreateDesign = () => ({
  type: Types.SHOW_CREATE_DESIGN
})

export const hideCreateDesign = () => ({
  type: Types.HIDE_CREATE_DESIGN
})

export const showDeleteDesigns = () => ({
  type: Types.SHOW_DELETE_DESIGNS
})

export const hideDeleteDesigns = () => ({
  type: Types.HIDE_DELETE_DESIGNS
})

export const setDesignsSorting = (order, orderBy) => ({
  type: Types.DESIGNS_SORTING_UPDATE, order, orderBy
})

export const setDesignsSelection = (selected) => ({
  type: Types.DESIGNS_SELECTION_UPDATE, selected
})

export const setDesignsPagination = (page, rowsPerPage) => ({
  type: Types.DESIGNS_PAGINATION_UPDATE, page, rowsPerPage
})

export const getDesigns = (state) => {
    return designs.getDesigns(state)
}

export const getDesignsStatus = (state) => {
    return designs.getDesignsStatus(state)
}

export const getTimestamp = (state) => {
    return designs.getTimestamp(state)
}

export const getShowCreateDesign = (state) => {
    return designs.getShowCreateDesign(state)
}

export const getShowDeleteDesigns = (state) => {
    return designs.getShowDeleteDesigns(state)
}

export const getSelected = (state) => {
    return selection.getSelected(state)
}

export const getOrder = (state) => {
    return sorting.getOrder(state)
}

export const getOrderBy = (state) => {
    return sorting.getOrderBy(state)
}

export const getPage = (state) => {
    return pagination.getPage(state)
}

export const getRowsPerPage = (state) => {
    return pagination.getRowsPerPage(state)
}
