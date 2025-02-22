import QtQuick 2.3
import com.syberos.basewidgets 2.0

CListDialog{
    id: selectedDialog

    // 选取图片成功信号
    signal receiveUrls(var urls)

    // 选取图片成功信号
    signal cameraSuccess(var filePath)

    // 相机取消信号
    signal cameraCancel()

    // 相机取消信号
    signal albumCancel()

    // 默认选取图片数量
    property int count:9

    // 去掉标题控件
    titleAreaComponent: null

    // 去掉底部按钮控件
    buttonAreaComponent: null

    // 监听点击某一项
    onDelegateItemTriggered: {
        toPage(index)
    }

    function toPage(idx) {
        if (model[idx] === "从手机相册选择") {
            toAlbum()
        } else if (model[idx] === "拍照") {
            toCamera()
        }
    }

    // 去拍照
    function toCamera() {
        var cameraComponent= pageStack.push("qrc:/com/syberos/api/qml/SCamera.qml")

        // 相机成功信号
        cameraComponent.imageConfirmed.connect(function(filePath) {

            var size = fileutil.getInfoSize(filePath)
            filePath = "file://"+filePath;
            var arr = [{ path: filePath, size: size }]
            var urlArr = [filePath]
            var result = {
                tempFilePaths: urlArr,
                tempFiles: arr
            }
            selectedDialog.cameraSuccess(result)
        })

        // 相机取消信号
        cameraComponent.imageCancele.connect(function () {
            selectedDialog.cameraCancel()
        })
    }

    // 从相册选择
    function toAlbum() {
        var imageComponent= pageStack.push("qrc:/com/syberos/api/qml/SEditGridViewPage.qml")

        imageComponent.maxSelectCount = selectedDialog.count || 9

        // 用户点击确定按钮
        imageComponent.confirm.connect(function(arr){
            var newArr = []
            var urlArr = []
            arr.forEach(function(item) {
                newArr.push({
                    path: imageComponent.model.get(item).url + '',
                    size: imageComponent.model.get(item).fileSize
                })
                urlArr.push(imageComponent.model.get(item).url + '')
            })
            var result = {
                tempFilePaths: urlArr,
                tempFiles: newArr
            }
            selectedDialog.receiveUrls(result)
        })

        // 用户点击取消按钮
        imageComponent.cancel.connect(function() {
            console.log('监听到---取消按钮')
            selectedDialog.albumCancel()
        })
    }

    function open(obj){
        selectedDialog.count = Number(obj.count)
        model = transformType(eval(obj.sourceType))
        if (model.length !== 1) {
            selectedDialog.show()
        } else {
            toPage(0)
        }
    }

    function transformType(arr) {
        var newArr = []
        for (var i=0; i < arr.length; i++) {
            var item = arr[i]
            if (item === 'camera') {
                newArr.push('拍照')
            } else if (item === 'album') {
                newArr.push('从手机相册选择')
            }
        }
        return newArr
    }

}
