classy = angular.module 'classy'

classy.controller\
('CourseCtrl', ['$scope', '$stateParams', ($scope, $stateParams) ->
  $scope.cid = $stateParams.cid
])
