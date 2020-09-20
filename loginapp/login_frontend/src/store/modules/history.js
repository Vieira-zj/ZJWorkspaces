const state = {
  historyLastPage: '',
  usersListPageIndex: 0
}

const mutations = {
  setHistoryLastPage (state, from) {
    state.historyLastPage = from
  },
  setUsersListPageIndex (state, currentPage) {
    state.usersListPageIndex = currentPage
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
