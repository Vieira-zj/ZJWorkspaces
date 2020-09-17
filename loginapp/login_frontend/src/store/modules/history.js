const state = {
  lastPage: ''
}

const mutations = {
  setLastPage (state, from) {
    state.lastPage = from
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
