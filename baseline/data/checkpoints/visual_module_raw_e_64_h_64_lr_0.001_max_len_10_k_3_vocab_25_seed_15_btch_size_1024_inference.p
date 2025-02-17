��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qXg   D:\OneDrive\Learning\University\Masters-UvA\Project AI\diagnostics-shapes\baseline\models\shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXQ   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XL   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   2386231526016q7X   cuda:0q8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   2386231527072qCX   cuda:0qDKNtqEQK K�qFK�qG�h)RqHtqIRqJ�h)RqK�qLRqMuhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqShh)RqTX   trainingqU�X   in_channelsqVKX   out_channelsqWKX   kernel_sizeqXKK�qYX   strideqZKK�q[X   paddingq\K K �q]X   dilationq^KK�q_X
   transposedq`�X   output_paddingqaK K �qbX   groupsqcKubX   1qd(h ctorch.nn.modules.batchnorm
BatchNorm2d
qeXQ   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\batchnorm.pyqfX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qgtqhQ)�qi}qj(hh	h
h)Rqk(h2h3h4((h5h6X   2386231523520qlX   cuda:0qmKNtqnQK K�qoK�qp�h)RqqtqrRqs�h)Rqt�quRqvhBh3h4((h5h6X   2386231526304qwX   cuda:0qxKNtqyQK K�qzK�q{�h)Rq|tq}Rq~�h)Rq�q�Rq�uhh)Rq�(X   running_meanq�h4((h5h6X   2386231526880q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   2386231523136q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   2386231523616q�X   cuda:0q�KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XR   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   2386231527168q�X   cuda:0q�MNtq�QK (KKKKtq�(K�K	KKtqh)Rq�tq�Rqňh)RqƇq�Rq�hBh3h4((h5h6X   2386231526496q�X   cuda:0q�KNtq�QK K�q�K�q͉h)Rq�tq�RqЈh)Rqчq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�hVKhWKhXKK�q�hZKK�q�h\K K �q�h^KK�q�h`�haK K �q�hcKubX   4q�he)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   2386231525728q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   2386231527264q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq��h)Rq��q�Rq�uhh)Rq�(h�h4((h5h6X   2386231526784q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rr   tr  Rr  h�h4((h5h6X   2386231527744r  X   cuda:0r  KNtr  QK K�r  K�r  �h)Rr  tr	  Rr
  h�h4((h5h�X   2386231524384r  X   cuda:0r  KNtr  QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   5r  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr   hh)Rr!  hU�h�G        h�G        h��ubX   6r"  h+)�r#  }r$  (hh	h
h)Rr%  (h2h3h4((h5h6X   2386231523712r&  X   cuda:0r'  MNtr(  QK (KKKKtr)  (K�K	KKtr*  �h)Rr+  tr,  Rr-  �h)Rr.  �r/  Rr0  hBh3h4((h5h6X   2386231523232r1  X   cuda:0r2  KNtr3  QK K�r4  K�r5  �h)Rr6  tr7  Rr8  �h)Rr9  �r:  Rr;  uhh)Rr<  hh)Rr=  hh)Rr>  hh)Rr?  hh)Rr@  hh)RrA  hh)RrB  hU�hVKhWKhXKK�rC  hZKK�rD  h\K K �rE  h^KK�rF  h`�haK K �rG  hcKubX   7rH  he)�rI  }rJ  (hh	h
h)RrK  (h2h3h4((h5h6X   2386231524480rL  X   cuda:0rM  KNtrN  QK K�rO  K�rP  �h)RrQ  trR  RrS  �h)RrT  �rU  RrV  hBh3h4((h5h6X   2386231527552rW  X   cuda:0rX  KNtrY  QK K�rZ  K�r[  �h)Rr\  tr]  Rr^  �h)Rr_  �r`  Rra  uhh)Rrb  (h�h4((h5h6X   2386231522272rc  X   cuda:0rd  KNtre  QK K�rf  K�rg  �h)Rrh  tri  Rrj  h�h4((h5h6X   2386231522368rk  X   cuda:0rl  KNtrm  QK K�rn  K�ro  �h)Rrp  trq  Rrr  h�h4((h5h�X   2386231525536rs  X   cuda:0rt  KNtru  QK ))�h)Rrv  trw  Rrx  uhh)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   8r  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubX   linr�  h)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XN   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   2386231526592r�  X   cuda:0r�  M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   2386231524960r�  X   cuda:0r�  K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubuhU�ub.�]q (X   2386231522272qX   2386231522368qX   2386231523136qX   2386231523232qX   2386231523520qX   2386231523616qX   2386231523712qX   2386231524384qX   2386231524480q	X   2386231524960q
X   2386231525536qX   2386231525728qX   2386231526016qX   2386231526304qX   2386231526496qX   2386231526592qX   2386231526784qX   2386231526880qX   2386231527072qX   2386231527168qX   2386231527264qX   2386231527552qX   2386231527744qe.       [�!>���R|�>���>���<�'�0u��'�i��=����N>fl�>���ݔ=x�P�)zh?߾+>y��{�>w[��       W7�?V�?�z<?>�>	�<?`w?��?|9�?�.�?�Zz?�?�;I?�z?�?�> yc?P�0?!`�?ըf?'t%@Ң�?       ��:�1�;GM�;���:�7>;�.�:�O;��:U��:2�R:���:Sv�;���:H.�;�$-;&3;�<��;�7�;��:       ?��<�μ��=��ƻ�=[�<�H���<M;��;�$���]�fȼw�,<�Q=���m�=�Y=wД����=�V�       %v�?��w?2�?��?>9�?�y?K�z?�x?��x?���?��?"!|?���?�Em?vs?���?
�?��?W*u?��x?       D            
��!�:$�߸αN>���=N�,��*1> kq=\��=�٩;��s=���=`T0>c�<w�a>/<𼕨1=US9>�T�=���=�:�B��=�m%>��=��r=Mcs��S��D��-��U�.��2�<,�->_������='�Һ��>�	��ğ���=��*����=*���U��vx���(�?�s��=�½�H�<����������6���V>'�>��:���׽k���>�n���#���q������q>����E�]���=�W>��=����fT�x2">�o)��f<˞��s+��RD=K齘'T>��a=gw9>)k=�<�;E���o;�����@��ɼ�q�=�t�=�8�/���{�=��v�7pJ<���AI��;K<
9�=K���(_��� e>c9�<��p��{ =6���(�=�%>h�=<)����p��UD>�(�<z1�&/��2m=F��=K��W���������<�<>p^]��P�=�?>C?�J��<��<_<٘j>s�<w�=,0>a ����=����dU'��m��D�(>sm#>���=�D>R����ý�L>_u��O�z=�(>�>==���c�=.=�#-G�&�����<n*v� �ɽ�|�=.O9�N1�<���4->�L��~����=�N >�j�X2{�F�쾽Z �U�����1f8=�p=ө�����~��<Q.�=�;O���^<IU�=|�=L�W=��_��}�=���� �p�vH�V���;>ʊ�4	7>i�Q<Kٽ�ل=�[�=%����x�<�s����)����Ig��㫽�?=�� ��?�=X��<(-L���&�V�@����=�l>����--	�CX>�����=V>��|1��h!>+�&�z�l�����t��U=�0|� #ͽ"�Խ�E��5h �q� <��ús�<���pϼ�5�<�!�<��e��7>[�U<�&���1;�����^�n=��>���;��;��,������=.@�=�=��=��=Qv�0��=����&_�����S���(D�1lJ=�̯=��=��<�.+�2F=���i�<��+���ؽi鶽qw��\8[�d��MR=�^7=5ᠽ�ބ�Uu����>u����Ҽ�"I���k�\x��ɣ<W���������6������>>PĽ��3�:��=y0�4�
>_6#��e���[>�<�<e�����T�p���{=@�Z<��:=�ʊ=G�4�[C>�ٹ<�-�=d�&��z-=<rٽe�-�~�;�/޼�77<���=����݂G<��>x��=�� >Ge`�l�<���=�>��3�]�=DA�=H���J��I�<�,4=��>�U=�~�wB/��;H�+��`}<�����н��?��;v��`�=�ȩ�9b���f>�O�=�XΕ>�S>u���	#򽨏�=-=���>���(B�����R=^R =7L���>�N���>�J��(=�
w�ֆ>�>�V�xʑ�!��=�ķ=���=1ؽ��=��=�~ ��a<�gg�/6���'>����	��	�J>�\Žf�=�����̓>&��=ꒉ�`$���!���R>�j �,\��\��,-�� y�i�����#��B��>�?�< E<q) ���<��>�k����=�=�o2;C�нUc��߅���v��ش�MhX=�C	=0�>]��[	9�s�$�g��'��$��t�=��<EC�=���=��C�J��<��>�j�=5!����kM�<�ؼ�!/��)�$pO=��I<�l='�t�;��>Qo=s��]�>�Z;�@�<����e�=��ƽxR�a�;]���=+�=�0>%�Z�#�q�={=X=���;�>��;�9)>��`��{=vm���!_=9�(>=�D����=�3�;b6����<��R�=i�����=�:�=:�=`B�=�������%��a� ��y����<��v� �ͽd��K���^����%�=m8ƻ�X���y>�#�x�E>�J=>D�+��j=�ֺ�(=�s@>N6��o�Ž%f@�{��E>ˑ�=
��zw^>5��=�Bֽ�=���=��,>,C<ؘV>㝼�=��a=��K�r�=s�e��Ö�43:=x���,	��TF�CF\���N�[��u-�=V:B���=�*���r�>��3���2=�;X=��1S=2��=����i:{=����:����>�V =��%>����Ʌ���A�n��oW��Mz~�IO3�Z�<s�X>C��=lJ�<�4��f=�s>[a�=��<q|��x�1>�3���E=���=�_c>G��=��=j�P���!�*�K>�_P<��;>�d)��k��;@!>V�=^W�=LI�ن$����Z�@���<;�7��:>�>�@������	i`=(}�>�H6�Ɲ�vO��#Ώ=��_��1�<��=�=�	8>$�콦Ƣ=�$�9X�q<ſ�Y�׽��<�v�������Rwֽ��*�މ����<��>��>=6-�=���=��Q�dN=��<D�1=B�6=n��=�+�=������=�u��ˆ���?=������:=�.�=�!8<H;��!c<�xV��Z->�Z̽�\>mp�=Z3���6e�o�̽Hm�>]1,��]=���<r3���=��񽾾P=��ǽ<�P>�T<==ü�w�<6�=��>��V>�=���m=�����/=:�%=��>�O���ʼV�=���<8ԥ;(�F��B��%��j�=��s={2��Aw�=��D��A�����= ����4���R��WF���'���6�f>�H���=��>���=EqL�W�=��<yD�=$����iz=���=�O=���=�;O<KW��bʟ<u���od>EX5�VnѽT�V�E���'�/�e=�n<�8���>�S=��ҽ~�;�}���("���:�2�2>���=�:���T%=������=}{��V�߽�y�=��<%���&�=�A�=��Q�t������<-�=�*�� �=b�#��D�A�d<��U�A�=�_���E=wt���j=U�>
Ä��p���#�aG;��<k�+��R&��"N=�:r>��=t����[=�s�a�=X�'=e0���:�=ol�=�[:��.�1�+���>�#�M@�^Ք��]>�y�<��ƽ�l��T�}�5�s%=��P�w�ƽ�:8�I����N< /(>�=�GW�����M�8E�=F�=�*��d��Yg�=� =�������4�<���s�"=�-���#=]>��绯ߥ<��=#n��T�!�t�AJ��ة���nd=��d�P��=�k�=V"߽Y.�-V��>X�һAAH�8���Z=��=��=����K>�>���=�(�=��8=tɝ��[C�:=6��P4�~�	>,���༧��=fkC��%��a��=��<nl���N��Ĺ��:��|W{�b��<ϛL��B��2>���]��<*47�xvY��d~�hk=h��F`�<+狽R1�>��P>9x>E�d>�J�P珽-�?=\�<�{�=au/�)���)?>��W<���DQ@�e�;��	��EO>���=oI���@�=�����ʼ[��=�v�tL�:N2>�U�=Q=��Aa>L�#���) ý��#�t��=]�]���0> �6�a�<'ʽ���>�����<n`����+>��cT��j'4=BL�=l�����̽H�a=�_�	"��"��`�$>\9�=�����n�=�c5�m��=H�<�b�����=���=��������a'>iy½7���?�Od������Wb����<?i'����CL��������E��=�zs>�ڽL��=�&ܽo8��RQ�DFн�U�<^�`;���Դ>L�%<P<ʽ�菉�!<Ԧ">�X���HϽ�"�����^#<U��[���|��Qz<��l>��K>~ٻ����J۽�I���T<���=�E�S;�=��S��Ԭ����S�=�Ѽ��=S?;�zG<�*Y��.%=S��T�L�!(�<.��<@��Tw��!>�w���L�<�Ds��� �s�@����<5ᕼ��;Ag=bD��p�<.�:�N�=0jt=u��<��9=���=��*>+i�N	m=̅��0����|�/e��/3��<>d�i4ս��s��;Ͻ �}>�%ȼ��	��)6<B�a���"��<��
�=�����vډ=Eٽ�	T>�|b>�e<���O ���=��i=��T>j��=�Za�쿦�rj=�j�=P�>>E�P>ɸ��(��$�i�O���>�˼�D�=�.i��<�=��E=Y�>�L"�]������=�A�����T���X�P��,!)��ڣ���=�7��݊�=;>7"�p�<5�|>���j��<�
�<l�1��轇���g�
�nK�O�=���Ƚ�H1>��	��>Ϲ���~=	��	��=���=T�E=�e=\!���?��.L=�J��;�>*D=Y1�=A��=X	%�2PM��5�=ă�=X\��+���Ml=@l������7�ow�;{d�<�괾$�3�����Ƹ��Fcm=Lzu�ϛ�=�Q>����m���oo��l��=�6=�ׄ=�A ��w%>{^��dw򼮉
=��<�R���5"��ʆ�؂=���<
f߻���ۧL=��(��Lٴ��1+>\� �W\=�Ϯ<L�=�b���O�Z쀽�ߏ=��O��/�m���ꂼ$�������>o����F��
�={�v��R�=V[ľ�ʑ��D<��v>�p>繂��]%>-�/��g.�`\��j.>QX=�ل>]0�<�y��+/�EH�Pxݽ���=�p�<�v<��=�x������9ަ=��>���=z�ǽ\��=��>��1��k���>�����=�V�
l�I�7��	�=�]�����='ĭ=�3u<�)�
Pn�7
= �=,���*���>ݱ�;���6>L����l=��y=�|>�)����=�j!>0�нn�P=R+�=~�n�:dt=T���Bd���p�=�V�=X�<��f�����U��6VR;'#n�l�=�e�=�>�]�=��E=�:��%G�<��N�U��d?�=��&��=k�:4�)��w�=���������U=���=ez�=ͮt=vHj=}�e=Ň[��,ὦͽ����2>��;l>cD=_�=���N��=��'��n����=�'�=$��<�L�<Z�O�)Q�*o%�d����3!��>R�=Jт=x��=��#=�o4=��z{��n%�Q_�<��*��2>dE�ܪB�J*<$�h�	QV=�*+��Y�0U�R��<�C<p�Ů����ս�8C=�(>�l�ra���=����C�{<%��=.�z���iI�\�>p��=;�Z��,�;V=�\�:u�W�k��"`�������=�=�
����]=uo$>�=Q;�-=]��=R��=œ��ބ�mR張=��8���,>��<���G�&>h���c#콝F�/K7������_5=�����G�aX�<,ӏ�%�����=����Џ�9�#=�1K=��->��S>B�m�G'z=U��=���5#>��^��d�=�Se>Q\b��,���^��=Gk=l�y>���0F����k�+>y�:>�M�=�}�=���=�B�����G���ð�'��)=�
��V�	>�5=�X3���*>�o�=��z=������=fh���=+x>�L�=a�����=m-����=0�ӽ�ǐ��:�FT!<7���_g=��v>]���������J=վ�8@�z����=u�$>c�bT�=?�����ۼ���>���=����Ȳ=0�.=�0>��
>��O�$^�<���<�'���T=_���%���j��j�<�=c��C{�=�l<
>!<H���X���f>�^��f���b;09�<�!��,�ol>�hO�n:��I�(>{bнr��=\�M=��=�l�=�a����\Q�;�ݘ>Ħ2��h��퐟��8<&�ջ��=������l>�JA=��=���8qH;*�d�,��W��=.�g����=4E>�|�=Pr�<k;�=�8I�f4��V��*tc���>T7����=�>���%S=��~� ���O@ʽ�����je>X;��rq<~�&=�qȽ-��Y�=(�=�ɭ<lږ<�=�����d��8`�)���=>�.��=�=�(R>�7>�{?���6:8+�=��=�:?�9>>��x�b=$X�=8X->����ѻ��	�d=��=	�>[�y=x�N=��B�8�=�Z<ä�F,���*�=p%{=2�	Gh�I��=:�,�ZFP��%����=E�z>���<�Z�=�<v�J=sF^>�ȼ��e���<M���:�׻Dص=D�<�.��ܜH>��üYr�����=+\S�`e��6J=К��;�<u�G>gE�����=��=�|L�qL,���K=Ɩ�=��_��X[�W�=Ϯz���<2��������;��<;���<�B���"�<��x=�]Q>Tl����Ž�v���_�d
�;v̅=g~>mA���/��R�o���Kf��z';���<r��M��<S@���d>���:�?>8a�=}�%>�eL�p�9���$>]ʁ=���=GMϽ-W��<>�������=sw�=�I>p�̼
|L=�ɤ�D'<���[Io=�5=�6�=*_��je>ؓ,=S��S��}�<O�>�R7������.[<�r�=&ċ�͝�=mx=���(O>��}��D���4�=g���E�v��>�b �	�
>�4�<>
������G���r<?�7�$�(��o1=�8���N=P��<��=��<-�ؼ�I�5B|��)~=0�=?��n���Д�e�1՞=�m<K�=�>ڻ��8�<���=��>)�?��U�=��G���=�p"=�a�=f1�>�f;	��=Љ"����=�p��� ����=���bq>&��/>,����?�<�Q�=�ᵽ{n?�7B�<�I=�w�;���Uڽ�M�]�w��>�)>��>R�ͽ2����Տ�Q��ܿ;:8�=e}ǽ����:}��B�T�=������75�<�����7��=]2">~T�;��P>�����>��>�JQ���^�%���p=�='綽� ��#ʽ?�l=�ջ�l>|��9h޼G��c��=?=��>N�����%�s0�#� ���_=�\*>ͺ��8�=d�O>�>g�=�{�>v[�=���;���=���B��"	>��@��6!��������ޕ=��c�%��=8��=B��v�G� yC����- ̽g��<_Wb��.N5>mFv��j;=��a=�Ԓ>Ëb>�G>�W1=�A��J=`��=��Y=�T=���=�zX�Zɉ�4h�u�G�aƲ=� �>Q6h�ƍ"=@ޗ�U[Q�uw�4�;2m��Jg>Y]>�Q��d=C�
=?<�����<�F>�L>d>s��=�D��4CL=�A�<a�H=�w;��=|[�I��k�������=��K�>~�����̡�=��N��:T>W���RC=#�ʻJ����E>�u�%��μ,
<�ǽ�'>�BӼ�=ɽ��7=��%�T��>[��>��	�zK���������=Q�p�	_%���<pt'���h>w��=��=�<R�p�V��=�����J�T�����4ｪzx<�=.K}���ʼ~��=�
�=�5�U>4;>�Y��$_	��&�=���=�y<�>8��9/��>4�!� ߄�(ټ�6�=����'�@q�;��=�{ ��;3���@��0?>	�һ�޽_=����=��l<m��=�l�t:T�(_�;���<�3T��{��>%�#�t�:��=��=+S�kg>p�=d�j�e�h�M��=���=���<(<�=;>��Ľ%��t�=�_`=�r5��:�<�=����A=_���E��p��;~n9>��;D'ɽ����U���"t�=��|<���)k�lt�=י�=q䰽ɤ�=�Mý7~���)5�X�={�<��ѽwS�=%3>��=�i6>8��=@�н�l���>���=�q>�`�l�0�׮R�
B��S4�=�����<����������~�<�z�=����Ģ=��Jش�8�O<�Wƽݛ��s(>Sy=���=�O�_4=�]#�N�y��7>b��[� >�5�<�l*��ؓ=��HE=��G�H�F�Id�<�8&�T�]�p�>�.>�G$>��>��<��=�֧<Awi=;~I�y�=�Kν}��=9�\>͖�=�n;=�}�=�=��7>�+�0@���`�=��0��K�<�>�<���=)�8��[>[��=� T����*��lҺ5�H>p��=��;���L=a ؽ�ç=@�=G�=2�$� �E�<� �T��<�ؠ�� ̽a^���=���<���8Z� ս1l9�-?��=)-x>���=l��=��i�[����=gT=b�7��>~��;�^ƻw��=g�=��==򋾽-�*��.>^t�;<�,>�W�=��<i>�פ�"%I=e�_�������6�H���4����<C�=�[���Tf=�L��չ����Ӓ3�O��=��~r�>J�2���3��J��=_#���)�4d�=�Y=fcp>�=�![�X�<���s���?66��{�N=�*>��=J�����=��=�:�!O�>h2��y�1���N=��V:ۏ�=�Ŀ�hн���<�ϐ��;3�p�N�+>���9��>��U�	w�==���=F��H��8�<	�f=R��=����#�Ž�p�Y���M�W���}��<�P����m<\=j>�Slͽ�	>��=��=�ᏽ�U���R=�d[�?��)����Fɧ�V }=I��X4�={��L%��3��NR{>9lǽo��<���<�:�;$�\0�=��=��<>�o�=KՉ�iF<$~�=�>C;l���� (>�>�Y=J%�=�)m=�=�=�+>���I��F)�Z@P�s���RV=PF���>��Puv=i&��^X��^�4��^��qؽ�=�:��GJ�pP����ڼ��˼���a2=����1|>��ƽ�Z>���q֣=Ǵ�y����=_�v�}P�=]���hS=	�h=:���ƞ=H�;Ji�=9O�>���9��<���=]�\>����
Ž��<���=/�E=D�ȼ��=&��b>Ԛ��B=�ٽ�U��,�=�8�=��)����;��=�e�=[�=�Z�=�j�=�&s��
b=������Pݼ��W��{
`����=.�e��=����H�,�>gM:�'"ʽ-==�+>�h��J�ۈ�ʪ�=����&�Z��:ۦ�=�c��7�ͻBxB>(�/>ϯ�=l����&5�&
�����
��=b<ǽ��=9���I�e�ϊ=1;<H9��gu̽�XP�S��=.>��w�=��=����� >u�3��<���Sս"ũ���Y>;��O=�x=y������#>L�p��;�=�MR;4�U�"[>�ƃ�>uj�>`J=�;
ː��7��UQ>ƪ������� =�Ե�=�
�WB�<YR������H�;x�:$Ҍ����=��<�l̽�`V�o��=��-=4�,����=*-)��)�o�=;9�;�⣽OES�=��:�]�ӌ��3�,�>͟ƽ	��ܻ�)>�^~=����T=5!'�ƽ,=:�=���=iA�k��?'�;��5>t�=ڟѼ�:�R{7;�96=_rB��=���=K��<
��=P�o�`i�=I�ڽSA6=E����m�;�ǔ�q�>���=^-ڽ�I��N�=^��=��'��Rh=��
>�c�>JP�<xH!��!=�h)>��U>y�����=_>'@�>�n�B��=\�<��	�`�=����[=_�=c���6��ne�<�N��	
��Gێ<�H>�g�� +>�-���b�;��Ͻ�'=��W>>Q�൞<'�.��k�=�(Y��"=�-s���<�f��;��;5�+>���h6�=��=�7����<vW#��-ͽ�:l��?k�=�,�'=�~=ӗ>�w�<܍�����>_>�@m=�~���ܼDA�FWR�*Խ	�>F��`~�=�)A�/�3>�޽N����A����[� �>���.>Qd>F����_==�=RW�=�' >���N��=��?�(<���E>�K��#s>�o����H����=���i�"=ӗʽ`�/>_�_�]j>�1�=	�>ͨ>�Ck=YN%�O�j>
M�����=��2�v�ڽ��?��=
�=$�꽔�7>�:�
��=��<���<}	3=Q��;���8Q�=It���gG<tK�<t���8��>�^�|l=�1l=zhL=v>��1=��򮜺�6=�H���=��(=|v�=%eT>���<�]L�Q=��;�D�={/=Fu=�󷼿�1>~�=���<����vr�{�=�Y���;Ľ��0=����\w=�����,;����,yf=��5=8��=�������Ə�R��<�U9��`�=G����R��C�tE���q��A/���=-}��T��V�ؾ���>���=�[����s��m=x���*�;9�r���>
,��h+ >,&�=�����<!�ۻ��v>8:��c�=��U�Ž�S�>��X<#���y>���=W��G��=F�=^�D=�T#����V����J�s��=��=7J���!��ԕ=E�W>���=�O���U�=�:�<v��s��+�B=8P�=�{h=��h���:��C�=�em�ɠ�<K�8=m��w�=���gd�f\ý��=�\�:�9=I��=��t=|h��+I�g�3�Ł��_,�=�ǃ>�٨��~=u��=x-ٽ!ɭ<�~]>�XH>�k<��|�����=�"����#�#N>K�0=+9�=��=�N*��,�����=�����4����.>�b>��#=˃����=��	��Z=���#>|�>��C>�����:�/�=��m=ch=vWF�����bj>Ss(���>"4������L�;{#������M>��=��>��ٽg|==�/>-�l=��z<j�>>Q9�<��=߬�=�Z�=��A�����=��$��r=��x=8��=NY��W�G>�����W���c=�Z=�*�=�p>�u�7�U��]��*>���x!G>_��=���5�u=��;�
f=�J��qǽC< ���:bUv�ZX��<�-(>�%�F�:� ˽�s�=k/=P��=[�&>��G���>M�2=���3+�#>���=�Ӑ=ib��"�<u�ֽf/<;-�T=�H=7�K�,��>C~-=f�޽��r����<���t�FS�A�޼�O�=�F>��J=Q4>	A����#�׍�=�ܽ�a6=��C���S>쀽�%���s�E>��>c�<��/��5=��<W���`>+�q>�q��<�B�5��=�DI�u ���;�=:�>�k�=tT>I�q�nt>�M=W���%(3=y�����>�r�=c�0ma��ȼn���٠�^g��)&=�"#�б�<4���kͼ:��=�N�=V�Ǽ[��=ѷ���̽$q�<�3���=�U=��;;�J=� E=��r>�w�;�P�>�U!� �c��T>z]�=p���C�UЌ�q��=UGD��
8�����)�b\�=���󝷼�Ĳ��>�J�>C
��&/{=5�63(>Ȗ=����-��)�<�v/�t���(%��������3=pbe�´�
�=|�5>Bw�=�ýi�.�<����=�v��	ٽ"�a������s����=U�f����=h�O>�^�=��=����e]�)=�]�an�S�໾�O��E�=�%E=�>ɘH=#
�=�Y=�9��xF�=4����G��!]>z&(����?�>�d�
�Q�b�(=3���`�jA=<�\�����=���	i ����=��"�=�_=�+��&<���<R�?��	�4�f�i�:�;^�=2�z�-�=Ѣ�^AT>�V:�o��QT�=q�=�ܑ�#���c�[=�½F�(��>=�<�=��(>2��=�x����=N�������0sG;m:�����=J75>ֵ��ԭག�>�����7�[�׽��=�q>�B��]=)��-���W=t&�=�����g�=�F�>]��l��=^Jz>������Ԃ��>#X>��<"|m�J�I�~�>��=-퐽粻=�>C��[���^����<�L>��=+���ʺ>
�R=��>ި��°�<�6h>xdo<䱽r����Ž0Bҽ!�<���<}��=X	���<m�<�O�<?|"�<��Z��=EþyQ�<��&��R��y
>�W>@F(=��<�`.���
;}9#�:�=:����<x�=�0�W��=��=t3>�t������Z7>��p���|Ͻ���=y�=?;�`/>��G=�&<�7��Ƭ=|[i=dI=��y�������c<A>�96>x\&��=�yN>�!˽��=��>7�\=*�6pE���!ƽ��=>��h:^T��^��=�V��q/'>ڑ�4=�I�=�jƻ:5
�6`��}����At��+>>Hu�<�ҽC�>,-�H=����`�r���"�SO1<*]B��w�<=���==��>g7��w*9=
r�=��<��/>��=�ɽ	�<T��W�2���'>�A>]�=�x�ٛr��
缔I=SfD��;�'9�c=�,x<\��< �'>'
�=W�J��������D��=��B�����1�ؤ�=�޽-�����]�����4��>�q�=Ա��yz>�,��T?��< $����g��;����9ݻr� >��F썽���<�;%�b��=0粽n4�=�z >����<�o>`�Ž����bnB���+<��x����]��?��=�8�=�G=�e�v|���[=�hi>�QO�NS+��'�=��bډ<�Oh�6��:[�eu)>�5><G��/G��ƙ�g��=U�#���>��B��}=�z�<��>ˆ�w����=�x���@>����6�;���=v>���{z;�v>V�
����<�P�
p=u�K�V׼ܠ'�-��=���= ��=f�M<c3�=�>���<������>�'�=��<O(��L�=:���ȷ�=L	�ur�;��>��������� yS����=�=���=���)H���� >5��'�7�!\�=)�_>�^�=���;;pi�4�j�򊜺����%��<]��=�*F<�R�����<�>��&qg>l�B�7�M=��3=�n>?�>�
�=�JB�{J���ɨ=a[ӽֈ�;.[��?򽖍?�w�>��=T$3>4��<��ս��-�u��=�V��u��<L=����{V��_=PĽ38=��VH�?^���r�B!ۼ�>�t�<��f<>��<;
>r���+��1�R=��=�S�<�>T*�<��R>:�㻫��o������<f��?��<n�<*���ߵ=	d��>�W[>��=#�ս�X�����=��<�(Ľ??>�۰���1�^�:�V��,���ɞ=��>t">�>�(�=f+����<�R�g[`<�!�=R�"<��<v >�$ֽ�ʟ<���;��B��)��S)�<{H�=_� �z��<�)n�Y)>��/=%�ҽȕ2���S��D�<��!�7��=z��<�\	�.�n=ʽ��ez�=�B�<�C=L�UPS<a!�=��s�\F=�6��]�[��F�=�i����=ξ�Lӽ}�j�F�-��C �L���=ʽO�<�&�>o����T�<���͓�=��>���=����� <�2�=����=	>��)=[�"��o�=VF�N�̋=�������m�>�������=G{�<n��=X0C>�c�+���H)>�(�'>��<�L�e�ͽ��#k��P#����>���=��b�)��=Z�=��b:�aJ��A���"�0�=��?<*�<��J�T�߽�t%�J�=G��r��=�^�����wQ	=�=T��< B�jJ����_<�K>� =�2�v��=��0ҽ��>�����$>]�T�0xH�laD�������S<�}d>_a=�����j= �>T��+G��i�$>NG�<f�=N�<0=D��=&����\�<���<�$=� ��k�=8S�=ع�=V|��t��=ڊ<,}��5���B<Sb���������
ɒ=g�*���ǽ�4�^w��	���%>/�>���=pn>�U�=�ڶ����=       D             ���?���?1�?�݉?��?�.�?i��?��?5��?|��?��?���?�\�?߳�?!��?�p�?�#�?-��?,�?̀�?@       �kg���q=���=��ۼ
�f=�� ��6}�Ջ�<���=�W���w�=��i�Z�4<��>��~=��1=�ib���>=ߞ�����=V�=V�.���<��:��K;>�<B��=�U��f�ڽ>��=d�|=�����Cg=Q3=�.=轨=|{d��7=��=����j�ܽ-N�=3�=\8�����ـ=�׍���=8��=?�¼��:�ا��ڠ<��,=G��Z�=L�=<k_=f��=�$�=>�";a��<uՑ<䨘�       D             ���?�?P~?B�~?0Q�?�"�?��|?2
�?�!i?�wp?�/�?�.q?�s?�s~?D��?�?�p�?g�?��?9?      �����=m��ml���d�<��v+���"��l�'>���Ɨ�=�h�3h%>��������Ւ�s�=	4��Sj=��c�=�>j<��=;�O��l����Y��>�����Q�>�2>ʠV����nsV��L����=�����#>"`y�Kۼ�J齹�<��bm>���=q(L�����!h�<(��;�f�� -�s2�=�w��u#�vT�U�u�&d�=j��L�ͽff�X���f��p��=�\��.��E����'��T=7�=#�꽮��\�>s�=�s��$�:���<�7�[C�=�1=:1�����<$B�����*��=h�n�����U`�<���E������:54>6�Ͻ�ڼ���=/�g�a>�<`�$=��j�@�=�h��h�k<�N\=���=8(>H1����j��q�rn=R\q�=Uyv�:|/>!i:=�ʽ^cO<�U���ӗ���O=.5�=������K<M���=��ֽ��Y>K��N��E�J@�==��<cR�<��$id� '�<�(>���;sY8��
�<�y����<ɛ�=����<>j�5=9e��<�>>RQ����=F����=C_�i�B���=�����>	��<>��=�L�<�	>����.Z=��������P�=�R�=��=�3��喼z�<ڢ�J��U^��A�;� F��݄���=�� �����>0bϽ8'"=���=�b�<F\��9=�K�x٨=8P�;ٱ!;<�f�(�Q�#=�սá9���i��yn=4�P�Tsj�𜽩P>`S�=���DVv�ڦ�<9�<�>�"9<�Z��]� >�.��򕼳ɀ���=4�u��m=������?>�d=ո����=�8n�+=�=QW�<=ʡ�=��S=��q�\>=h��=����v@�=#2ֽb�">��|<��<C@@�
��=O�*=c�<s/�;k��s�����=��0�>jԼ���Uc=ґ!��,�����=0�=�-��x>�k�=uѽ��K��&�F���0�=@�<�*%>9W�=���=q�ֽ��������w�U�_=�#W�i�>	�=؎N�"J=�ۊ=�w'�7�G���>P1.;i��=F؍���b==�:���!��o��=�1��쯼�>>��%����Ѝ>�]����<�3>�Է�����}�&�(w�;y��wԒ�����X�U;�V��ֿ佑1@�������N)�r�>YԽ�5��iH��g|>��>�Tk���$=q����jA=�=�\�=,�ӽ��Ҽ?ٶ=*�����=��Z=K�Ƽ~E�=��_��7�<�v�<7���qm>�õ;G�U�m=ݽ��q=��������=��G+�=�J�;�uA���ݼ��8>�N�7�����=Kl��/����$�kϽ�!｢�'<��z���<�l���߽��>���К����=�|��U�ڽpAD>�J��	�z,1��<������j��8�\��HW�461��V\>�c3>�@�<�׸=�r<>x�1=�[c�*��=K��=������`x�=Q3Ӽ�!���!�+�U>��= �������{!�u�b���:��9�ʋ�<ފ	�tD��/>�P�=�,�<��彃2���%=�x����(��.`�V��<�g�E��=��<D�f��9�B�t�jp��2B��\~> ���Ƚ=Xm�=��(��l=B�f�ľ�sE-=��4<x��<Ks&>VxĽ�r�<Q�=��"=���C�p��1�+�⽧_��r�=�A>��{�g�ӽI�߽"�=���<��=a��"�<��=T+��h ��Jk����嬮�;ҫ����=���B>$���3�����=�:�J��=����>�J���8>G�<oqA��$:=P^Խ��9�Z!���\�U<Q��;�NQ<�!;�=�P\��*T��NG�(C�=��b>�\��W��2f|=���<A�l��=}��{�">�>��ɻ��=�\�=���<�7"=$�=�ӫ<d؏<��=~��=9�r=���=�M�;�H�����=/'����=5ܫ���K�=J^����m=���=3������0�=$A�=;lнv�;>3��L=Ϩ�=״�=Y�>��L��̌�E> �P:rL�=y;��.�p���Fdc>       ��=\!A�+D;�$c�TG.=�M>> ��"z�fGF>r�F=��=�I��q>��U��|�=Gwܻ�:�=�2<>�ܼ�O�=       �!�(GD�P�<����BU���/��5�=�޼�]	=�I �ރ�;�;V=�uh�=]H�v0�=����D%<Pԕ=��W����<       �>Bވ�	K�=�<=y.@���w�8��=K�
����=i�W>�wڽ��<�5?<�'ɽ���=�0�]��=y{=>?=%�D=�3�<a�������<Dk >c6���v>t�f��I�=u�=��>7�'<�8+=�p�����<ja�<E؞=��>�"ӽ��3��T�=��Q=ܔ�R��<���=j����G=�=ջ�=�?=ci3����=P�=T�O�2�=�v�q�3>WtD=�J6=���ީk� K�=�j�=�O弒E�=�8�B�����|�؆�=����Žރ�YĆ�G7>=ؼC=�Y�L7��>n=�x��+����=s>="=���=]�ʽm�=�N]=w��;]����ӼK
�
�H=9�5�-s������,e����&>��P=-0l=�#�;8)���S��f�>�X9�<���=���;*�1=���=Jy����t��]�=�$]��>h<��ͼ�=ۊ��MD��	$�=�w/>[�d��=�<>Ez=+|d=-�!�j��=�Mp=�*��Y?Z=|���Kx�93�j�9����J���8��y��2>ۤ=�]��G=�E>8��Jl9���=�'M=��<�Q<am"��{�=K��=�O��0U=E�=��!<"�@��hT=���<2�#��^�R*ϼ�aB=�:�=�=���-������=��>q�=<������iد=yqݼ�׉�T��<³� �=�}�=�J��軽H6�<����/��v �����=��5=�<�뻼���=�����>
d������J��s�V>89��f��;x����V�=�n��@n߻T��=�{�<��޽H�=sW�=H�~<N�=��=�~>=���'�C�<a�=�y>$���P�ҷ��$/=4b�����Խ�w�=�:���P��y�=��)>�׽&� ��$��7y�b�����:
-U�r�> �6��[���.=]D�:��Ŗ�=tY�<�-�>�b���Y�"ټW�)=�d�=ra{�-X�=+8�=G6>��㼪��<^Sh<��o��=�a=��+=5���_�Լk�8����<���=�G�=�y-="�|=�!-=ّ<Gj�=>˾�P?��]�k=�"�=%��=�����F{�E�=�� �%��b=\0>w��=c��B���Ay;9�T=<��=T�=�Y߻�����<�:>_��=�'<-�r=O-�̏1=L}/>�i�<
����Y^=�¼�����G���=�֖=�/��k7��{>�a=9@�;��D��*�=�u[��o�����1���=_p��ѻ�d;�>=��=��==3;ȼ3o����=tx�����=n~e�8���Sܽ�<�=b����0ӽ#�;Z"=�P���!�<��q������=0ǭ=�[>	����c�S��=zV=�h�=xŽ�<��p���<��P=ŧ=Q�Z<�ֽO��=��`�Yf�<eP;���Aj�.Z
<��;b�<�C=�q2�ׂ�<��=�Ǻ=��h��.Ҽ�~����]�\������	˜=�k	>��b�E�A=n�V�J��ki<�ӽ�J7=���;��+��սCxz=���=���\)�X">�t�<ZI�2�'=_�>�<�{M���>���=�L�=�t�1$�=Ag>I��}��>�[v<4�k<kz彄�F=bL�=I}�<B�< �Ig�=zcq�9m�;��=�{V=�;����>�M�=����kr�< �;�~�� =u�;�N�=�+=V�=�pֽ�B^��P�<϶=�c�<B�2���>?�V>�*��LP=�N��?��;��=/��=��9����7�53)�RH�>���f7=^�=y��=c�=
( �.����=��=OZ��4��>,|�����=�Ro=H�>�g >��>x��=]iX=�>S� >��z�@_=���=���=vu��p1�^T��}�=��=��=%�+<G.i>���Q��<��?=�o�<�逼G����z=z�˽
 �J�=D�̽6�<9%�=�1���==v�j�%�V=כ�=��<��޻)@�=�!�=�?<yQ����.����I�>����j��F��4>�Mչ݆��{��I�=0�=�d�<�1@=F�z=�ά�5��<�>��=k��=���=�>f�a>T���K7�� `ѻ��<? Q>��y����y=�����F��,�^:*;�$5>a�=�]���<�>=�n<+y���O=��>bMμu���J���!=���<���q �ԕ���U��s忽����[2=sq�����=cn�����=�;=�a�=iuo����=����O�=�$>7 y��"�<"�=L>:�+�=Ï��#�߽+�<Sk#=N6�XI�2��ԋ+:��SNȼ$�> =n©�)�>�8o�g�=�|����Jk(>r1>�#���,=ƦW��������g�J=$K�����)(<U��oH>8">�.���}=X4[�\H�=���<{tC>7C>S\@=���<�f�<XG߽�M~=�:Y�'�=y����ُ=Yp���H�=3ˬ=�g	���=}�==+f=� #>�3�=�=u�s=-լ���s=�9�����u܄�D6�)�0=]u-<S��=[��=���=�@I�w�=�>�K�:	>�Rn��v�=p,�=�9���a >h��=V����=�A/�����=���<�Ë��
=�3O=�Ś����=���=^�S>(<�<�U�r�$>�?>�J����=�=|�<2b�=!3�=�s��4Ht<��`=U�=�֌=�S�S��ᦅ=�6K=�]i=Ïe=����^;�Q�=��]�(W��k�=�n>�\�=g����>)$�=�����'=�N��{(>�W�<�=�q=_?5�Ej���H�=��x�1�׽�>?�=1ԋ=��/���<=�ƀ=E�0<މ>,�<��=�w$��:��`[=��:LI=��ۼκn=���<Jp�R�b<�"ͽ�>�=��=�E����d�E��=�>���X��%"�=G)2��:h=O��=n�<}3=z���=<�L�%,�6�轧=7.�=Ș%<�7b<��ܼ)�c�[.>+ 
={�]=�d׻�v>��=�V>��=�ݼ�5���<�!�=�I=�b�<NW�=��=�% ��A�����=m�=y�tZ(�/��=��L=.:��@�#����wci=�O�=7ܗ���=��ѽ���=���8��:�N=��=B��V�k=d�>a���������<�:=�i���xL�{�3>�	ȼ�|w=���;"�e�Ζ���،�'��<PK���9=pn�<�z#��о�VuŽ5��<GL[��K�=�����������=V��=��
=i�� ��ZQ�<���/�<��9�h�I=�^�=B��;[��=���Zd�=2n�=uC���=.�H�=��>��4>`�����֩;�]�R=e� >h����μ�K>񦑼�8=c)V�o�n=�T>��=����%>dz7=h�:�<���;Y�<� �9�X��MA=f�L=�=�7!<�ض=op�=1�j�y,�=#F>)�˽��=��/>o��=���<y���^V���w<2�>'�5�}=E���IM�=6oh=�>+h�=�s�=�)�=��};/SJ<~ �=�AZ<��ѽƤ��Ɵ�D�0=�����w������P�=sY�=X�=���r"">;D-=g�}����<��>�X����=}��ِ��%Z��`w���K=�
���6=�x�<�)��[C����=1E=,U=�$��[G��!5��u���'+����=d6�<4�ҽ�����"�=�ѷ=@�=��:���B>܋=+� �dJ�;w�=~ F=�$>.�s=&U��s�=~�>���=�f	�����xQ=�C�=0��=��7�?:��5<~�8>�t�=I�>	��ol�=�O=�*>	i���>L=�bw���>�䊽D���>j=�M����=.��C�=cǶ<W�ǽ�hl=��G[M=Ń=�i�=���<�/9���>�u�(�;���ѼSY�<����f�=1�g���=M>U�xt�=k=�ۄ<��.�&���`2=�F�=�)�=�G�=qI��(�������,=*4�=��<��L>�R=2����.>m��=a�_<�/7=��=(�*=`ii=�A�<�4��=��x={�{�=��˼,`�=đݹF�=9IȺ�B0�y�>ݾ��ư�=�>�l�=�8�=F�Ͻ�ȇ=��=m�0�A	>�ǃ;kV�=�L >i�:6�X=H����A��:=&&�;���;~���B<���=������8^=k�N>�=���=�#{�Q��<��<;;��h#<w=(R<�~h=�.=t���ah��� ����μ@�=�Ҥ�:UW=r�z=�@�>K6(�,m�=�AҼ��~=�:=>u<�"q���<�6<*ٿ�K�M��`�=�q�<`9�I�!=m��=�/=uPݽ�M�����<�">S^6�V(�=���=�y�=j&�<���^�=�n�V�>n;�����?>���=Y4�T_�=X�z�5���D=a@>|=����Y7]�����*ýVڰ=�1���º�������=2�k=���=�'�;�ow�}&=���={ݠ<��;v[�=p�>Ā�=��Ͻ?~F�0(=t��=�έJ�w�l=M�b=��K=R�=9��=�=W�=���"���<`� >����u0>XR�<�UE��9 �I]u=6�=Oּ���Î�=���=��<8`�F �=Q�=�H���=Bj�����=q��b�g����&>:z��X�=S�<Cq�r�ٽ��=�D|�W�����'�=����4{Q>�\2= ���k�=�s���x��Ͻ���+tt=H�E�~�<O �=
��< D��C�<���<,O�����f#=b�Q=�Pa���L����V=Y�<*J>���=W꥽�ȝ�ǡ>�2�=Y\_���B�颉=lA�=�=�)�M^�3ԉ=ݴC���=������'���hS�ݙI>�Ķ<o~�=������d*	>�A�=]u[�T�=NӾ���z=��<����Z;-=��<���;�=A;	>Q8��fL=l�D�����ȇ��y�ɟ{=�l��[�=��=��>�k&��1#���U�œ��:�=ˆz���q>ʹ=��8��=�T�=� =I���Y��	^ҽ��=v�C:gJ������L�<���=x��Ε=��N�E�>��=�y�G{��ś2��Ȓ=0$�<ܺ�<�,����m<�*y>3�t�!��Z>3�3>f}�=*F&>%��=��S��/�=Q�F=F�O�d��j�=mo���8�����+�6�_/W��&=��>z�Z=���=�b�׽p=s��..�"."����>o��q>����=�q�=����r��=��&>�u�= ��;b�@�>�9<~��<ˠ�<}k�=�~�=�7Y�o/=�֊=���% d��B����N��a�=NY��"��=�7c��F>2ޫ���=���/O9=R(x<���=�Y׻&�>p7=��<ː�<�ڕ�#r�]5>梘=Y�'�Z̽=�VM<�)=��I=��E�
2R���>�np>��=/8����>���=.OԼr��<���<��=�cӽ,2�=g�սp`=m}3=�]A�Ѻ�JX�<҇��LD�=J��=�1>-?=�"�@f=�B">�޼G�=���=l܉>* �b��#�Y��}�=6�ۼGQn��t>g�2>��=�!�=��5�襞=��f=�h"<+��<�C�)��<$w�<{<�ew���B=��L�����=a+ ��.�]G{�H˽k>,X�9�ǽ׼�Yq��Y�A�"����."�m�h=��=6����P�<���=�׻�AK������.��;��R=HE���<G�>4J>rJ�Z��=M��=�,�=N}x>��O�T��=m�; ���Y�:ݩ��$������mŽ����7H�Y��-�˼>`��E�=�'	>Wl=
Ə<�%�9���=�/��)d�ʊ>�7��d%<9��<�Q�=J�"=�ܽ0q_=
���>��!='1>�s =6+->8�<�>fj�G���;���=�(�=��=�.I��\=���6^>_�<3� �?�[&U=�h=�F�=���6�O��b%=�(�:C�)=a��Z�=˂�;�v)�+塚Ɇ����=���Y=��_6���6=��>��⼲��<�m,��.i>�z���JF�;��|<��<�~�=zC�=���=�=��=�����=}��;"~��f��=�g��.�N�F;���4���3�=���<�{T��~�^Q�j1;��4t��=+� B1>f&�=6��C�=tQ,���"=ա�Eä��Չ<u΋=��0=�8�=���=��\��=Q�ͽ�M���s�=7�=�V�=:XP=�]�="/��e>,'>}r�?�:=A	��Bj��d���>_@�=����4=pb=k�ؽ�\V=�I���\����J�=�:�=�m���=��O� �=m�k=�f������:>��D=g��<���<O��<�T��;�>�^&��2x\����=^Tk��g�=��=�,Ľ��=�#)�"��5l���
�=�,>�(�="��=s!�����~>]��=������;>��E=D'�;M��j\��Ʉ�=G�=��=��9=�w�'"=C<ikܼ�ī�iq���=���<�ĽH�9>|(+>����%B=�:��B�X>�}�=߉Z���_�g�=T=�:R=L(�<&K�������=�#=F�>.ℽ`��<>]z<E[|��K~�&S�<�}�=/h�<��=瑕��A==��/>k!U=�
|��s=��>�B��KR����$�BWk���d��>>�j<�F;X_S�o7>���=E�">�	>F�<��Ⱥ��׽[�=;��=����r=���3u+>�Rɽ`�>���=�ܨ=�p��ߞ!>�=���<Tq2=�׽V>p�UBn�f�=�1�=�ㄽ����=
>���[(�=���e>
t>�tZ=���<jZ��/p>��ཁ��uG�;,:�=.�c=wA
>K!L=���=py��%�=�������=�*�-m�=���=�o�=��=K�`=�H*>�]=�����h���g=�ݽ=�s=6.�=���=�u=kdS��o�=KNM=i(L=�|9=T�>�(V��@>�nA��_�=��ĽY�Y=?��<�p�=�]^=DG4>���[�=Q��=J	=�gֽ�|�+����3=<����b>����Ni׼$��;e�V>�C�=���=�	?=��=��F;�=�"����j6h<Ѵ�<��Ȟ=��>�R2��?<G'��#Rn���<��>~~E>�O�It$=�b�:���=��=�g<IA��#/=.��=��B=E�w���="t��JM5>!g >�]6=ME�=׉{��@�=��*=���=jWi��w�<���=�B<�<��]�=��;#�¼4n�=;G����=Z����0=���-�=q >yN�=Z�����6���>�쯽�~�=t0％�z��X�=��<���<�����܉=�X�<�=V-�����;aBH=���=Zs`>/�=��ƽ���E��=?��;�����<��o>���=�s<b*�=׵��ڹ
;ˉ�Pj�=J�=��=>��r�6R�=yb�=I��=J؆�~��Js��>t<�>3�"|ϼ��t��=��K���+>�"���ح=������;�K�=��7<�<��=��o�=n��=`ɸ;��>��c�>ƼC���Z<m>K��,s��`=շмĠ�=��=p
<L�Ͻ>�>FoԽ�� >�w'=<o<QW�=������=xzq=���=�L(�!�����X=��E=Ȇ>B�1��;�2�D/>�u�= 
>����>Ň`>i������=j�v�<.��>��O=�@>�9E<F�ؽ�c>�m�����u|"���>K�7=
�J>O�</'>��#="�=|=�<�>Q��v=�`�=��l�2����o���<X��[52>F�>�H:�ﶼ�t|=�>+�=h�=��=���;��=���=yߣ<%?�=yec���>Ⳑ=Q�=$LS��	<�>�A�ݹ��j�=�R���7�=~����"f�dЀ� !�>���L�=@P#>LF�<H���oQU=m����*>,}I���1=���;1��m�=�Ċ<��ȼrZu=Ugk�D}<=��=���=�ƽdHl=>�'>�/	>xm|�R����D"�*�>1�9���<8ƻc�>���=:< <�f,>Z�>z�=;+�t��>8��=};b"�=s'Y�����s���~ɱ=E�j=�Q!��S�=
Xf>�\%�W��A;��<=��=.�#�Ճ?>�iݽ<�c������=�!�<G#Z=�$�j��������}�r>:�=�va:+rp=�@��X�>�9+���;H*=�U<>l��=Ӧ���+����;F:>����*�@:Ӂ1>�K�=�^I=�ٝ�H�=p��=�����=�g=�P�=�r�7��=pσ>?u}�2/ڽD���~>۸=B` =���w�=p�=t�=�&Y�S|��w�=�jԼ!��F�=�� �@�Ľ})<Sc��%�<C�w=ژ��w��f5l����=i�E=�$�����=*��=�,��i���/�<$�$>���=���<��`���=�֬<Խ��>���=��=͟;���м6bl=';
>F��=U�
>���=Q���_�=��=��<�	;���=H,<�w���=]$�#��79{=�(�=s�5=2F�<YD(>r|>�v�=�ނ==t��=,
���P=��=����|=��=ܿݽ��<�<��$�Q�վ$�QF,>Z�̼�(��X�J=�p�=Ht�=�=#���v��/�>|N�=�䷽���=�"->V��<��VBR�����h�=�-P��R�<4;=��>E'�=�u{��F����=���<���<�U=��8�Ȃ[=����TY>Cp�=/C���xN�;b9<�R>��B<zнln0�(�˼�T��^�߽ۚ�=<�<=�>�*��=rP���U�=YǼ"|-=)P�<{;`���=���=�z@�+�g����<v�=3vj>>�>��ʼ�����h�>����aP�º��g/=�M,=^QO��㣽%�1�~od��;�=�=K���d�=���=> h+>��]=�����Ͻ�v�=6�<d��;OA�H�W>�]�=�����/<J=Bh�<;��=���ܷ�=������=�Ϙ���\<�';��,>(���M=α=
�(>J�P=�k�A>=CS仕R�<O!W>�%g<Y�>�MJ<�&>�C>>E=�oT��-7�o����¼��"���=�d$�?�=��$�����G�=C-�gx�������:U��=��=V,6=P�=i]�<��z>޼/=&�]=V�����<ŉ>!wR=�=Z��(�y�A(�od���k�=t޽#ן=DA�HI�=���<�V<A�!=�&>�!!>�v4=\��oW�[L����=�Z��%���-O>���t:$��=�=4��� "��<>�T!�%��=�[/=��>߂��?=���=?�]�׻p�1�I2@=��+�.�~<�(�=�$>m\r>��WB�� >1dͽx�><��R�m=���=���=�>(=��'=�)v�����4�VZ=,�;ٚ����&>��4�h��=�h=�Ŷ=�3�=¤>ѧ�<;S�=���=C�2>��n�R) ����=UC�=�U,�F�=Q۲=>|fb=D���/���<��K�H޾�Ӻٽh��< ȼ�i�<�K�=g�=��V�ہ�����=[��=Z��=�5f=U���⼋d��V�H��=R6<���= �1��=�D[=���C�	�| ����<�&��x������=G�>A��<q�G���>�!>S��=;+���������K��<��=<�ݽ/"�<�ʧ����=����e�=`H�=ec����U���=�R<H�����<"�>�y��v����T�=��x<��>f�x��F��������"��8�:wtg�A��M|�=O=>���=<��=�e0>E�K=wDg=<
>z�=��<'���D����;v���Z�<z�<��(���=���Ұ�` :=��>�ȸ��X'��"Y�j*a�&��=�
��>���=��ɽ��>��-�<��=Z%�=�z~����<�*�=��;�.> 7��Q��=p��=��,>����������=ؕ��,���W��=c�&��h=�n>>�i�:�D;���=�<8��=×=_�=�������� fP=_{��%ed� �!=t{=�F=��3�w?`=փ�=��=�l��%k����=��5� <=�ZϼM��#)�=�C>g�>|��H�>;��>��n(������S����?n=��=n�<�Ƚl��=�|�=R�=@a�3�;!�(�9�3�C�P>Ula��C�;�s�<���=G����ib���=��N>m�=(�>�����a�=��|=MŽ�5w= �l>Ʊ=�>Ə���������=ƭ�=tT-<��=�]����<,r�=�����렻�><���YP�;�]=21�=~F=�;�-�=H]���Q��!D.���=Ξ�=�B�=E�#��E4>P�a��ă���l=Y��=G@8�fؼ$��=�[�= �>q 3�<��y3�N{>Z��=�x�=z�ֽ�v���0��f4�R��=�u�5�/���F=�;ȼ�{W�woսiz��ʆ�A��<�@�<@6X=�]ƽd\�`~/=27>-���s������Ƨ=��޽�E&>"�=޸�2$�=qܼA�=��w��>��6��=R:�=}����a�=*��=�<(;�N�����ϧ>���:o���|��eI<�,=">�)�;X4�;��'���]�=WH �׆=��=��h=�F� ��<�6_��lp<|[��:�=�y�=�ж<	��=+^>^<޽{*��2i�=k�}�Kk�<J6�=��O�8��=g��=��=�>�"J�<+�<��仕[����������Sږ9qt��>��޼�ܱ=������>��*=��0�-�=�`�=|&�=�S/�� </_�K�弦j�=�	�=���=�n�=���<p�,��B�<ʨ=}i�=�Z�=9�<�/=�q�=�9�� ��2�+�
z >FW�=�U =��2<��
=��k�k�y���D=�)=5q�=�齆��=������=�>Ŝ��[���S7�Y�r>�k��kJ��L�?=������	=k�U=.*Խ�=;"�=�
�=���=?�߼lp=�p=�|3=3�!>�ƺ�8=$����=��=	į=%��Ȯ >ř�=mn�QFĽ���;TtF<}������U�Aڐ=�l���b��[����=;��=��^<w��>3B�<��D=_���	/�4�]>���<0��<�,�=!��=z�ܽ�^�� � >���=2��1w����J�7�����L
�R]�=�/�;%]��^��i�=��=9�2=a�s=�~�=v=���=}3� i�<��n�q�>ü�>�ͽ�=�5��W�/>�^�=G�">%+:==1�C=�|ӼX"h=���<���>>�E�����=U5�=h4>�1p==���ՠ=�+�=c$�2=��r9!���ν�K�=y�>A�$>$r��>J��=��Ѽ�e[=m=3q�;l��[���ȣ������v��{!=�lY��H�����Ž���=8�*>���<G�޽�OI�w�6>�gi=\��<��=���>D\Z�X�d�Kw��4<fPK�Y�=�W��n��=�z�<q���7�B�=V�=��=o�=��'<�Ö=g�;r��=���=���=�f�=P'P>&x4;�nU�t(�=T�<��<�۽Z5>��!�ҁ(;�q�=��"=ģ����>�Yp=X9�=L'�=	���G�=S>�%�sN�%�1=&|r�� ���ˮ=��̽9�=C-=�l�<?.�����=I<J=��=� �=�9>JM\��|A>�ԁ=uf=��۽�p�'s"��&=��h;G?��L������=/_):-��=������ۭ=ɶ�<"��ݧ��dp=���=��T����J$���m>)<f=Ҩ�=y5C>-$=�==��7�@Ib= c�=R=�]ν\�=F��=|c�<�h#����<���9���n���;��<p�`=�4���k�����=��$����<;>�9�=D���]�^ux����aT>��Hj&=�IS�xi�=�=� =�#n�|��;��(��s0>��N="�1�y�I�%�>=$Ƿ��p�{TM�È�<�u��G��� <9��=·<�Z>QjP���Ž�����4�_���b�����8>0��3d;�α����=(�����=h�=���[�<���觗;�.p<H5=����H�=�t��(ͽq��;��<�,ý����T���=E(Ͻ�q=�jٽ4u½�=
>�>�饼-;u;�)>���q�����=�~=֍e��!�;jU�<��'=�y���D�=1l�XC�<��Ƽ�n;�:O=�p�=8����5�؎���8��E0�{Ϸ�l�{;'ʸ����������Y�J>2s�����<��=Q�����xj���N�����={��=C� >9a�=s��<4�C<s��:�����H�={8�=��|=�,w�/����ۼ�TH>�[ͽ�ʼ��#<�ઽ��=�p-��#�=�>ԁ��m���P
;�b�=%��=�!�"��>�>��<�_���%ؚ�h��d�ܽ�!����<�/�(V��/ڽ/v>��1:IVg=���= �ż�>m=�����ٻ�}��Q��J�I�)׼R�����=?��*t�;��=�,=3�=4&i���I<oļ��ύ�$=Ə��^�����{�>���=�M3��B�<	�=H>��~�r{)>DY�=a=gA�:�S���<�; >�.=�㾽9:��J�r=�l4���>��	y��w�����m=�yU>��]=�o�CX�>
к<�
=ML���(��7�=�f�Y7���	>��M>�N��%޽x>�=�q�=!;��*�=���=��̼1:H8���,�<y�m=q�|�U��=/<��
,����=F3=R����=+uK��U7�3�0>�=��׽�m��gzü�e�=P���Ћ�=���;��h=oUk=),x=��Ἇ���>l=�����z=�U	>���"i=�e���B�d��=�s�=�|>�����O&�Q�>>���;	��=Z�+�^Ҍ�n�&�9㮼��ټ��ѵ$>�͐<��*��|��!�<Kӽ�O&>JȒ=�m�<���V��=���f����aH�8�>���<㌮��9X��`�=Q=��!=�<���u=��?>z"�<�g>!��=�T[=��=�l�=O��;�'���=�@D<b=�Z6<�x+=;�(�<\<��Y>��#���T<��=��<<?+�<��=��=�.{=���<�E4�U��"��=�kx<��:>>C=�q=�>���;�)>�t�=%����Xr=�/�=��=���=&�=χ/>�M>��=�5�<N��=�E�<�U����<2���V���uy[=�{���.C����ż�=ַ�=�
����;)z �2����T>]mY=Km�=�Ý������=�@���,�X�<�T�=�թ;�I{��`5=ay��1Cp���0<>Q<d��<p�>v;m�z��=ɏ�4�<=�=h�*�(��Ѻ�<5ܾ<�gr=~_����<ڔ���Y=��=y< T�=���=vC�<5�����=<G������~n��g==�B����=�=���=b�(=�ླྀ��=�����7&=��#�=�}�-o��EZǽ��ʽ�q<Y7���V>�dF�<���=+��=�I�;%D�����;��=��޼�u�=Ů�R���E�q��=���;�s����)�^�8=K�>&�0=&����=���<�v�����ٍ�H�`>B�O:ӺX;p0ټV~>XYܽ���<R�=���=@�>{	���`=�<=g���w��=>
���(�=�i?=8�c=Ic<^�>D��=<'�0��=��N<p�:ʘ=��ʽRQ�=<�#�t`=���;%�=D��9DEͼ�kw=�>�g��e=�xV=�w=��p=c�2=��e4+����n[�=�I�@ݼ��\=I/��e	�,sc>���a�=��=F�=���X4�=��̽�J$>�L=�G^�yR۽"81��t=�4�����'���<�I2�Њ�BP:>��<�'�����z>����ֽ�J��g>B��6�佀W	���=MP:�'b�
$=���=��޽2@8�ޅ$<D>���=]��=�i���P����=Gs6� =��=}&��ZF�=����H62��Б��@M=)�=��<#��<��5�U�"�í�8�V=0��=�㝼�{ �I�|�]��<p=̺~=�6��ev��^=�� =_;~}�;R`��9����d>�+*� �>�{����.=I�.�pF�����ͼYD�=�><N������1@<1�=^[�=�����T���=P��=�<Q>����.��*r��_ >�>δ�
낽j[>��=x�=�c{�(�>��=���,��zT�=\D"��I�����)=ӄ�=0p=�dg��3v��d_�"t��86z=r1����м��(��<�b�<�1���Sͽ��)���?=�F�:k<��s=�����=A�Gg���L=/�=���d?ؽ1)��A��=:�?\ӽW1f<�7��NT��%w�(������8�w�q����J��:j��Pw�a,`�l=�۶�Ϭ?��gl=D�]�4��=&'�mܴ=�*�<�D�<��<=
�ֽw�=Y�q� Aݽ�½	���ȋ<�D�=�2{<���<��	=8wڼd��D�R=S`���Ĥ��	�&��)�&�£=h6����o����K�;����G=Q��WS�=�ؽ54����3�MvA=��}P�=s6�<O0��Vu��tQ<��=�箽�V�=�=>S��=�����<�0�z��[j:TD����_SI=XꦽYx�=��}����]���њ
�޽�J�<����9+��q;�;\�$��븽�<�mE���<O]��}>���=���=��"��w>UD�����=:��i�=&*�ɹ��@�k�ӝL=�q5�cQ8<��ٽ� �=��x���<ͽ�u��=�	=�B="$�<�]>c�%�!�Ƽx��={�>5�=t!�N��=x����z��q�=k.G���>7ĭ��� ��_�=�y�=����^�<�E�i~n�S`>i�	�0U!;�+ɽ��P>����Z��fR�=,"���=�=m�����=
��,�~�v*��|�Ϋ;�e�I�I�_�~`�=�>=g�E�A�>u3��C-��(>�P���6۷=�����.�x����M>�e�;����*F���>Zw�;�V�<��<+��=�D�<n�=�+�=\D�=����'�{j=�b�=P��=��=���l��>�n1=;�=Hߣ��#�<i��=k+��HD��)����c==-=�:,���d%�<f��}�ɽmn�=fW>DHb�uĽ�^����=�o3�7g���
���5�=���=������=o��=�Q�<@�_;���=V�|��>>��=�h󼷪߼�U��/�=��ջ �}��=���=
�>X�>b�)=`�=��;�m9>'ʽ��X�\��=m>�=O��Z�~=˖�=Z��5/Ƚ((L=������=���<՟,>H���k
=�2j>v�����3=����1�PE�.��<��=-�=��J<T��=W�ĜؽJ��<���4���^;���`>[��򟍽"$����=dZ����=p�ü��k=�$�=��`�K�=ſ�= z=�&'=�$�=컚�>��m'�=��Z>Ȣ��p��=���=��=��=0���=��W���������>` 0>y��=K�=�~�=
�I<Q���I��<��ʒ�<�sѼ~؜=@P�<j�&>��=��=��7<}0k�R��=��>K�!<�}ϼ�e�=s���K�Q������C=f8�=���=�q�=Db�����=Q2&>�>��|<�R>��D=Ŷ˼6:�=���6�һ��<�Z*���׻�=(��<����<��=�/>P�X=�Dz="����&<������=��<�K�=�<��&�=� ,<��M=���uj�=�BV=&-M>�x��|s=����Ϲ=��&=tv��;s� ���ս���<�\�=bG�Ƅ��p�=t�t=ط۽_��`l��S��K�ܽw� ��V�؜���= #�����)ͧ��衽����8x���#��8�<�r�F��Ƕ��U�콇C��P�V<N\���4ؼ)��%�s��T�=kG������]C��pҽO���I�=��X�aCK<�T��𽑍i=u�6��|�e�C=�`���~��	�=��=��.=lv*=�;���ka=�߽��V=�}�yDC��d5�%k��廊;dn��g�<�Y���=fz=cz�:�P7=������;<����e�=���j��=A��0�=�&=${�xV � ^=6��[��=G�s=���0�=��K������L=�Z&>-Bg�`�����-�㼛�M<���=A�ͽ�;ݽyg%�($�=W`=>'w�i+?=����?�=�;>�.�	�=���=�=�B������:��6>ESӻ
���W��j�=���=������W��S�C(�=*�.>љ�=����{=x���s�m=�5�>dET�֦�<���c�=�v���W=6�d��->ʌ�==�H������׮�@cE=u4<����S�2Ɗ=���b/b��>��g�=����/�����A=n+o=-�y�o�潝���.F<��;=}���[
.=$ez<X��1#>/,=���=�C��?�=;&V=�I��\ΰ�d�y�b�$���s=(�=&
.<�Τ=Rl<��=�W��+�=�G�=�p=��}�@e�vO�r���w�<�Nѽ�0��ߡ=+�c>k�1�L)��,����=�k������=h4-��U�}�=�N��m<"�=,z�=��l=1��\���Ԙm=EX�=4+�>���9�r�����=��9&�o���E=c;�'�>4�4�Kjż���<��;.��P�M=��=��<O�,=�U<�8x�$Qe=/	��;�=�f߽n|��t��0>��ȗ��x��Bٟ�����ࣽ0M'�vp�7ה:��}<~���<�:Ǽ���9�˻h������1�=�����V=!��<	�=��Y=���u�=w��<��\�!J��㺽����F6��H=R��=��=�A̽���	��*1̽��=�H���7B�܅�=�I����Ѽ(z`=Hk��խ� �ƽu7;I�;�P�<�&�>v"<ƬӽʲY=�$��@{U<L��=Q�;D�>�>/���z�=T�S�>5F>���~�<�ӽ�կ=�	q�����i����='�I�o���"\Z= L�=��<���=����=>�]�n�>���}Z6=�4>��=��=Y%�$@�=�qX�l�M;�=exؼ�/�=��=�P��x�=^�Y���=���=�f`=�9�=�ʇ���>S��=߬;1�>�������ب�R=���t�=\ t>ղ=l��ٝ�=���\�������=�B)=��<�:[�CLI=��"���z�d��=fr��zn��"�<mw�|4�=3��=F����=��<]�ȼ�.Ӽ٧�=���h C>�'��t�;L�X����=ٲ��qÊ�P,�=�6�<Б6=�U�=AA>�7��;>8��=I$�<}��<a�:#�=v�2=Zͫ��`�8�$>G�=��L>�t=:�!>j�R�����ee>oj����D�xl�߾�=���=Q��=�>Sa�=>��t��<x�-��<�&=ޚ9�.��j�����	>Ù{�LN�>#>�"غ~>���=3����&�W�J�à=l�=*��<�����M'=�[ͼ[>R�=VA=��>�,}�YB{=!�=�X�=v�*��c*>$�z>��&=>D%=�H<.�N�y4]=�C�~�;5o,>�b=��~>��� ���ƙ���3�<:�6l>����3>y��=��!�|ő=��׽� �;M=����E�5=N*�<�p��U�=�fX>����+1��k,Ǽc8=4f�=H����@>��?�9
���ִ=]�	>Fݻ��=Žg*�=j��=�8���=j�<T�7�״ý�Dɽr2�=:q�<tq�=�<�or>X ��{ݢ�f�;��L>�;�����='<���w4�A��eƻ�^i=K�<�Ҋ=Ъ�MI�=lY�<#C=N�D>"�޽�`m=J굽ws���=��v=�>l=��=�i-���üu,�xg�=e�->���ﾯ��5@��_
>?������f�	���ɽ�-�Ⱦ@��M=��=�>qK���<�sh��5=[=8�*\V�����W>�5M;�;x<�/����;^Wǽ[������D�=鑙=��}=���=�B=�]���*>��B��μ{��=�+�=49�=��=�T�=��=�=5=��ོ����=���=�J=�SC=@�o=�0">�sO�t�:=��<���^g�=�9�=$h�<�<A#��鐼~I､|սW�s<�7�<�	>�+�<mq�=�}�m;=���<�\ ��zN�h�g<u��>�5�<,>=ۉ:1��=F{	��Г=I>l&>�6<Z��<I9C=�]=���=�ᑽ�_�=�E����w=[>���=�Fļ����~�=fz�4p��"�= 1�^=׷��}us=�H޼�?/=��=.O�<W:t<*��=h6c�omm<��<�Y�=�m�=<C��h'�=N����=�2�Rͥ�1f����=�(���.E=��a�I�C�3���Ů=�@Ͻ�ص=�8X�kTF��m�=a�=��̽Qym�@Q�<�
 >�E=:��<rå�Ci�=;�=��=ז��ؓ�d�=�>�=�5*����=ħ�=|�F<����m�<-��V-�=f\=K�N����=�i�=`�=�&C��~U<k�4����=���<ș >�:{�z�=����S�ҽ_�n=}�P�!j+<��ؽ �D>���C%���� [=�8=�Lm=��ü#
:���'>{�s�Eռ�҄=G�=������<�[����{=��=\ =;�з`=%cw=���=��M=���<ކ�=#'�=�e8��A�
�κMZ=�>��=������>�-�=b�J=X��;c=�=�=�k=h��=G���I =���<P>�X>�s�=�P�����r���=>�B#>ܽ�=8�l���Z���S���gK=�6�=�_޼�K�=[k�=�c�<�p��0�'��{R<L�7��;�7�=���=�d>�3��|����a�;���=~��<�T��9���Ds="*T=W^>��z<Ő�=���=�j�=|R:�3>����� w>&ݤ�h$|�:W�<� j�����u�=|m0=��>��=����=�X=w>K��=IU[=�1����?O >4=�>��7��=�W >u��=zt��.=�LH�(O>�c	>+�A��`�� �
��¦<z2����=䝕=��a�|��=�=�>�C��3��l	�=-YA=�B�Hd��Ay8=+x>%k½ �3=1s�L4�<I�fÞ=z�>8��==ڎ<���"�>A�<��T<���_��=��X=%z=Lzӻ���=;&�@�P<بb=���+����=D�=�V�"��eWL=���n=�����ͽ��<v�����ֳ=s0�<����L{��~��;|���=7P=X��>'� �&H�=�L�׃�=���={�W�ean�`�	��9>��Ɗ�@v�;���=g��=r��=	�4=��9=؝�=M��=h~���ﭽ8��=+�p=U�=��@>�M
��논N幽Ά���0>�w����<8�&>�p0�ΧB<��n�$��<g�;H�����,�)A���U�=^>z���	�FY��=���=�-^�ԛ�=��>mб�!�==�B>n��<���<��+a�<�C�ܺ�=�O/=r����<�� ;��<���=p->�U�<UM���<�G�=��=��=8,�����=��A4=��=��Y=�н"����;B=t�/>�p=���NC�<e֯=�?�>Y�;=Ì�լ=�'�=ɍr<�/�<�R���T�=��;���=��P<�X<m���F>d%
�Ǯѽ��C=*���j�cL>�>y�?=	sܽ�
{<&�>S��Z�<�4>莿=;ݽ��<�����;Y���m�i�L�=��>=��<��=k����[=       Ug����h8��0�1[f����܉<��¾���=m��e_���@�8�`�˾�������P���ν��o��=       ��D>E�.�i�/��|�=����gO�����B>�o�!�)�`S7�dX�N|�=a�a=�킼sIq=���=V�)�|^�=EOd�       ��L>ѐ���u��ٶ= ˼�W������C>4��]�"��)�2<ٽSA�=�h�=�ӗ��1�=�y>���ey�=`k�      ��2�\�T�.�=���!������=|�߽<�<)	�Y꽺�佅������ɸ=�V?��=9�=d�_>��6��3,���
��i>(!ս��&�|xp=�|j=Ѱ��*==ǵͽ�����e�=�ʟ<Z�8��=��f�@'+���j=U^��#;͠O�2�*����H��<. �!P��뒾()�<�9>��ġ��2�:Q;�m�
O�='�I::ە�%rc�<�A�=r�ES�=N���']�E�=_�o����<�v�=�٭>}��<��$�2�<��n����6��_�=��4�H,�� S<�k"<>K�=�D9�s�U�=��u�;K��=�̼p��<)�b=��'>�8=�`c=}k~=XA8��U=U'�=XU��h;�zI>e���5f*>�
�=�q<G�[����l% �!����=>u-#��:Z>�X�˗��>������8�Bl�=���|���Y��\�=).B���9EX�=����=�A�;��=$䚽9���Q����ǽz�$>Ҭ_=7��fe>�B��f��˽�G>��<�����<*��=����Z�=̐���ݽ�������q�}=�+��+���d��=q5��'��:y�'�G��R>A��=wO����/�+�Z�E���?8>Z��<�==�,5���6=���=�4)=4GE=�ּc� >_�ۼZFF�<뼤c�=����>U�>^E|���QD���K�@�O>T��Q�i=��I�٘ν���ʐ=g߼��� ��;}�鼅p
���Խ9\��l�=�=��6��C#=�3޽��=RI��U������=�]> ��=R�S�gx&<'
��H<w��=(5���E�=��½���5[�;u=u�>f����>B�3=M�:=��=\�k=��λ��ֽ"��<���>�~�oN�=��b�sN��'�<J�&�g=)�=p��m����=��=����91�	pe=X�=J
���j�Zc=P��<k{��K2�8����R��f=Yd=�`�:\�U��E=�H�=�n
���1��%ýy�L�#�a�;v�7>R��=]E=�M5��aY=�h?��I �@k=72;��{(�)�>����#�=��	>�q >R���Obܽ��L=T'�=ؽ�=2�">�?���p�ل�T��(�0>����s��="�e�IW�"	=��=*4>B��=�b�<��,>��y��>E��B;�J��nrO��b,;7�=g�v��*{��W��� �=��[=H<9����
���)>mf�:���>S�>=I����l>m�\>�)u=�d9����=	ڽ�#��uE���^=Y��=����I�����={;�&��<������~�4�=מۼ��!�Q2z��xv=��=kB�N0G����)<�=u&黄�ý�x=D��� ����3K>b�>T�o�޶�����<�`��Ȼ=*��C�9>)0�)=	>P#=?.���=�a��G<h.e=Ԩ
�H�>�?�=,�Z��{=xq6>륊��^<��3�=�6i=���ƺ>H�'�BlE�om���\�[������=l�e��lJ<9���i�,>���ݶ��S=,����47>��=��<1�/>������:�u�]H̽iз;��=�(=;e=uu������E�=��"�R�.=�H����5=�6�}=��ȾKl�=BvO=���*�=^�E=�n����(�x=}�8=�*)��',=T��,8=7q8��U��(ڻ}������W𼤈]=�/�=.��=%?>,�ս+7�����;.ib�Oc��I	�:	�Rc�Sˇ��L���0/���P��a��ઽ�ջ9�
�\d�=�Q�<,�>*Ѽ�^�;�D��;Y�<f�1�l/s<\� �� >u1��ĕ=���z�=-�>��B=I� {�<��v���<��>H���S���'�\��J{>c�->凼g�>-�<^˕�}쉽��=b���Kl���"�\��<�3	<���=/Zv��/������#����=Ӝ!�Y�)>d���"=޿�=UEf���>�=��;J�����<���M�=��=v>/��@>�>�V=.����Ľ��½�l���=���=d�s>��׼��U�<��ñ�<O���]����*�<�~�V,��jl��/�=��=*�>�?<ʽ�=��<�Y���g�xc=~��n�˽�o��4�<Ҍj<ժ	����=G���a	�F I>)���k�o���@�=hx	�q~��D, �ZZ=�LG=��*;g��d�<#��J��=y�.���=���=�2��ZO�<8�>�5I���Ƚ|SV�PX2=s�=a�p<K�>�r5��j=�ԟ=�wi<�CV>�lܽc��=��l����U�0=�Nt>J�>佣=G���->F�>�@缁��=ȵ���}��ʼ��Q>�$�=S>�n]��،���x������)������X9���M=�;5��<��=x#=����di�i�>>z��=lv�&����'������V�4��
=L���ƽ��7=?��=Ж=iƹ=¨:�R<��0R�s�;��˾���¼��8=�W���8��ޘ��rfX�G`�<�-���`���շ|=��м�����=�^����V�<��<$:=�uI> "��v>&��=���<͸�Z/ýH��t��=5�K<�y�"n�<��Ͻ��4�D��;��=<Dn�+����)�������=~�K��Z�=�#9>A�#>$F>7�����`��c��s�=�n���M��(�>��=��<󻒽v��;���OV����<�,��X��z�4�}�>Ӽ����#ȶ���7=���DyH��Sƽ��0��z:<��>w��'�����7T=D�G�������=
Z���:�L�=+�Q�bۃ=�1½K���>'�T<��=�p>%���:�`ٽ�Op=d��=�<ֽ�N@<�����>9\=�ֽ�>���(�����</yT>�@�r�=�n�>��o����=��<�z�=S��/�-�=#�=&x(=��=��O���i>de�T]��p l�Y�?>~m[�C]��6�|>� ��H��>+>W�=$o<F�ؽ�Ol=�}>Sg��#G=��n>v=f�f�>TՇ=�[�=�R��O�=�	S�c7��6m��)�ft�:Cx���^�,�[��dg=Kq>��;�^.;�_̻�\�B7��^D>�md=��=�k���T};!C�=z_K;���=)��C�(�}�����
�������= r�<5I�<D)��L���B�x�|�!�Q�K��*c��<>��6y��f>���X����>�t��V0>�,������>=����MD=(=�
�=�nY=E�=����vĸ=��V=��=�0�K�Ѽg�Լ�M��K�<�Xi����X὿A�=��;KX�=�����$�։�`����&����>,>���s��h	�|�;�L���
���=S ��<Չ����U��A@=Y�='bּsl��I˼�O�<�8�=?��}N�<��?���μ�'n>�݇�im������<���Խ��~>��*=ox��u�=Oֽ	ך��X������7>�9>9j>5D=F����^���`�=�- >����>�=R(b=��=�>�=���=��1>��'�N�T�թ�<�F*�z���I��O+��}q"����=p$,�7�>[l�<�/��:>E�<�^������=�1�=dst>����:���=��3=ۋ=C*�<t�=`k�I��=���=/��<�����4��`�s7>��e�o�5��I>����wO��i=�2�%UF=�I�<KE=}�:`�N<ߺ�:�����<�vi��o�=zk�}'���4��U6=���1V��pE(��"�<в�J�������T�%��V[=��=G����}�=c ���b�;���<��$=I��=D�(>��j��=���M�Ȼp�	>o�'[�=�>O>�Bɻљ%�̥�=]Ao>���<��<A����;JV��I��<i�0=@*���.b<%�����'%;K�=��ͽ��=�Ak=�1=3����`z�N����[`���<ԋ��@=����q=m��=���=E˞���콺q>s��ZC��5��=�4�C�&���Q�hA;��;X>po+���@�3�j<x��>���>��=s����ս {�<��=^���i�=�G�=�G�>N��=��F<[;��`r4�?=��E�d#�=k��㜴=�0�=Խ�y�<1�<��ʽZ^�=b�˼���=�ؽ/�2��Ͻ�)�<3-Ž��<+�8=�q��<.S���Z��¼�b%=��w���ĽF�н�����>>�_�=`�=o>=��q����=-彣�=��`;�甾%�==z��v���.�6;d�o=�jL>1�~���	=U Z�^K>��?���V�f��;ۋk��c��U�</0>0�=�sB=n�Q�0½��]=p�w=k��$È=L��D�=6r�=�l=�E���>H��<�"Խ��t�,4M=���=e�<1<2>3���_��(����;�Ţ��Yj�W�`����=%Z��3��<�X���)�;�߄�\阽ι��f����+>��|>��>������	�wߡ�%n�=`Y��ֈ>���cr�� >�[x.��:%�?Q���:S>S�7�e��������<�:�v���~�<��l�f[����)� ���\zU�����;^�r<�m��q*��󘨽�є����r���ܩ�}^�=�hG�}���]ƻ�����2�����c�=����@ӹ�Γ=�T�2�˾�=�5= ,�<gH�<E�]<�+���;�ؼ�� >�\��I/3��t�=�;��N>zZV�� p� D���\>%%�<�����=}Dǽ��r��8B�{�>ce�va��oJ��T �fx�g?>��߽{ef=�m;�7V�;5c��b�V��"��8��ً6=���=,�׻?7�<�<�:w�/�],˽ܫ��8=�k����н��N>����^�^=:�=����̺�>~D��Y#���~=�=.>�8��_���8B���W;�i�=����0j��}�>�����=�r��������=�u��"��,�9��Ƚ���<k�>K�=�ɽb������*��<*H>T��?�;�
�@q3>Q�>����KW
��P��U����ڼ�,@=�� ���%���|���ڼ�����=d �=4���kS���鹝�����<�ս���=!RY>E��Ϻ:��vƽa1Ƚ��>��=O���F8�=�Q>j՛���i�Zo�=�mR=`�⽅K���e
�+0@>$�	�&�»�ܙ�$ߐ=s�ýj�,�RA{=b�轜F��ʍ>��ļ��k�ƕ���<����^_<���BQ={�>n�0�.=�[I�<K;�!�<O������,�=�1��<2�<9�Q<+ġ=��+>z��<����S3�XH->�o���x���X��8j:�E^�l�.��R:�f
�=� >:�Q#���m=��=�o=��7�����j��=�u�=⧽��=e����"�w3ƽ1��==)X����<���;�D=M}�=�^>Q��=���Pd��;d>�N��̃�Ԅ*�vJ�>+_:�_���_<���9����c=N�&>��;�-��A���iT=&��3X��̓�¨2�J ?����=z�'��Դ=��~\o;�E�oL�<��>�/���<������[3�o�X=���:8P��Ŝr>t^��H����>9-Ƚ4	��a=��Ձ�=zv�= y�=��=������<#YQ=ɺ>G@U��v��=�}㽸���x�%��?��}o=�VI�b׽9�"=H�=�<��=����4��N�s�#�>���o�X�����1Y��(]=�G�=5�(<���)6�<�1H>�j��&��[*>�X>�4���>���6�<>��b���⽊!�=�#����>���=!V���N�p�>h]9>8ݶ<��>��%>1w��bz
���>�G'��5</=ځ�=j�>^�����=A:���r����;�Qp>?-+�m@<�3
>L��<V�kt�=���=�rٽ:$�=�Z%��W����⽜p=��/<��->�2�=.�<����)�=�=>3>�U���h���ֽeՌ�Gĩ�wY���=�皁=�M=5~����Q���(�!�y��B�_���a��ze;/}9�����N��=��4>���9�*�	ƹ=�D�=��>�w�D��<�>.�PzϽ���%��=9�㻖�F�fZ7�I�<��1��5>��?�*�|>�[�=�٬=I"'>���=rm�;G�h;��� ==2�=�(�w^6�	f�=���={�4>rQe>=�z�=����F���I�'�<nt�=a�8>lK=���=Ac�L�;=������=Ɲe���ｿ2��	�9>1U�N*&����>�0>�u��_���=��U��r;���d��>,�>G7=� �<����A,>��M�Ӌ>V�νh��Z�׼f��<�`�<�_�=Fi ����<���Y�o����&=�=�g=�� �+�Y��&���ڭ<^��o�>��y�^�l�a�=�,����=���=6�=�xc>g��=��}>�Ľ=X#>̾���=��:>0*ĽV���e����=�����^>k򈽈B����=�
��=�L�=����L���F�>"!�W��=W=>��=�}��/&/>�;שм5��=�.x��Q>#��>�>A�>�v>ay�=�=�<�xy=x%�<R��<�|�i&�=9�<��[%��_̸���U,=�q�Y�>TH="r��V��E=��1>]s;۰d>�Ͻvm�r�">6��[�=�l;~�S�+�绺W�Lwv=��e��~��?�@=6�=���9�����=�~��~�ѽ�E�=�xS�4G�=UY����~�|T�>Rڼ����G=��q����=���><!&�`�=�D=�!2<�X_�h��ژ�����<���hх�<��=��g��&�`�<�:����=��!=@ѽ�KF=Ϝ�6�<�u=�M�������6��U�=/���.R��Qٽ�Y��G#>:�M<q���2�=��%��ԃ�k�@�������4����<F-_>U�.=ŵ�<9HF��B�<��>	����M='��O��=^̨�p�=ACL<���Z�t�归��<K���x̀�5����̽��2�=�8�����u���4@>�#�<��>�2ӆ>�[�=/t5�8�U����,[=�]ν��V��l=�f"<{6	>�(�<��X�T��F��ʽ�+=kO�M� ��\�߽ͨ�7u��$�=��8���B�R=�=Qb
>�|u=F�&���<��G��������<UԽ��_>�kW=��ܽ�Y]�"�<0SA�8镾׀���=�B�=�G�=��¼m���K��=CV�=��=:��0Խ��J�.je�
m>�0
��Lν�QZ�5>��;8�T��0==P+�=��߽�=u�����ؼ��=_I/��7_=Ɠռ����;��&��/W|=;��=�@2���ݽٳ�=n�g�[6q���Ӽ�7�=8H���&H������n=a��<�������eH>�ܼΒ�6ض�Mý|�a�>�2�g�>kۅ��k�=�Ռ=�Kv=�6��ߢ�=��=���=ϳ=1YE>�[8��q:��9���H����=ъ)>}�:�0,�چ�=nֽ�ý�"��Rٽ۪>�ٽ���=� :UH�N�>�]�TCݽ�S�⠂�v�7>a�q<T2G�������a�d>��w���X		>]ɿ=m3&=�S��d���q�k���� �=��9l���i�=�=p�=+ݡ�{���.�L=]0>�8z�aˀ=d�@GJ��x= ʿ��A�����=D�>�����>���=��L�`�=<d�)>B(ν|�ߺ��&:S6��m��=@���{�:��)<0�*�b*<�ʽf]v>�����O�\�N��O��uT�"����Kh��Z�>+��U:�=�v>$�<��<^���穸���!���w���A�=�^4��?�G��=��2�<M=9δ��:��{�>1��
�=]�<[s��S@a>�#3�Ƕ���5�uo>�`>��A��غ=�\>1o�\j��@#��g^��)��V�&��<YG@<�	=����1�=m`�=ˏh=���=�>��R=dX�;-�߽R9,�3���Ϭ=���=��=ź^=0�L=$���:�>�|�=���g�0�ww�0�<L��D.���|<c����.>(��=�R��i�=_��=x(��>�����s�p�;<�<bu콾ڷ�D���[�=��;=��
���.>Jټ���=cA�<V�C������=��=;c����=.�d=���='>�@�=d�>~�����*;�ɭ>H�	�\���i~=�{������s<{�F=T��<v���J������X`>y�;��ʽɤs��֬�;{�=kw��M�=�����b��d�=0\8����<��=������x�=!D���'>lz=]��6��?y�=����r=�=�>�y�=RC>��ƽ�Ͻ�k?�0��=�*z<'b�=s�=<�*�=K/����!��=�T �*SԻ��<e��=i)B<ץ�����f�7*T>q�=d��=��Q<���=)�=�[�vpҼg�w�!�~t]=�O�=(�=1��;�=̟8<.5���o�=@C��GG=�n&=�}%��=w���:>�@<��H=&.���'޽�2��T=%��7�`<�Q�Hղ���=Y�G>�f�����=���ф>��<o�4=�ǀ=o�y=l�=�&:>�E���3����>=�b3���u��π=���=+	>@<>��	>�M�<�PC�<��<g��R]�Fr�<A�0=ӵr=%%	>@*��6޽��|��Ǹ��b��OO=T��=�ઽjr�=�j4<">�O�ox�;�_ڼ�\���<����p�=�`6��f���h�KІ�#F�;��߼(��;�����>�&�?���ۼ�KL�����}0�r輺���>S�Q� ��;�2>	�����8�]�V���-B2=w>Go������J<��-����2w���>��μ���UK$�+S7��h�u�ϼ��'ὄ�#��B[�x����ӼeE<=ͯ1��A_�]�g�hzD��S�������m>M�ͽh\��j��7ݑ��>�=�ᖽ�g��&=��0�хi���=�T>��ǽ�)�*�">b'"�,`[=uy��^�>͛�=�G�����AF��d�^���1�+�=>��Ի������<5������<AB=�'��l��)� �>_뽁�D�%<�<�2˽!;�=�A�=��Z�Q�><޻����,�&�l=1w�,��=��߼���<33���˼qF�=�6�����&8��q/������^��Od>�߼Cw����=���=���l=��׼,��;�.=Z�������k�<�4
�7�'=�>/�>M�
>u5���&=�ԛ��ýҜd��Yw<���=m��<i�=�ؼ��	>�3>}H>zK�r@>c�ϼ�H�=�w>^L�:s�T�<�}�B߱��x���ȵ�c�$���ʽy��=��=��<BHF����=��#>�OO>1{<�1w�<�\=E>������<�N������=n�>	p�>ԫ�>��Z���b����<l�n��� �
j%����=^��v�d=��v=^v����>>8PP>����qv�=Oh��~ ���[=�-�=z=k��9�(�UH�;�Љ<1y<��h=x�%�Q!=ڋ��s� �lJ>N��=�l�A^�����U<�.�н�1����%<�j3>�=��q�c���V���'6�=FW����z�����'�=7�= 䆾O�<8n�=�N��8'<X�<�;��<�
>% ���ӂ�gk0������묽���=�3�=L��<L	�<�|�����B�'�5=ӽ����='P�<\�Ž߳����S�=f����n�<d��o��<�����=���#>�t=S=O�m`=��s�2��=H�н�;1>n�	>���4����7���q;=ۃ���>W >z�=A|2>�:�nք�('c>{���u�U������UT��ӽh��D1>��c>���kE�T9���<j�4>;�+�߼X=�>j.�鋝;箻M��#� �`�&�0bp>>(J;�.�e�%>�$ֽ]�F�����=����^y��W�<x�=��߽�z�@[S�:��Ao��gF�=��&;����f�`�z�\>�����~����<�4�=���<xX�;H�=�1׽5� ����<�}F>^�+:�����=����.dZ��5��ƈO�*�i=��8>,�̽CV[���y��AA=R���R�=*�=@�L=!/x��ۇ<����Z�Fu�=}��<��ҽXr�<x�=���=δü�q=�y6=dc>��$�=/_b��'��k>d�گ?��6���6<7Ҵ=X�:�
v��"Z^�C`�=@N�=���L�}�Q?>Hн�Z�o(&=���;�{�=��=�� >�׼t5��Y�U�x蚼��@��a]>�G;@������{K�f����0>SK<>���=� �=º�=�.Z�z�v���w���=�;>��>�I���4ŽY/{>�����=��k�Qb�= Ռ=�I��N���,�ʽ�O��>+�=��;]�޽��=�l�c�8=�zȽd
=�&�)_�>���=N�<��}� >�=5�=DF�[0�^jֽ�� =�==���M=���<ƻA��mi>��۽���>;�ս��ʼ��4>���<]\�=�2��L�<�v*=C^=W%e=p����ѽ1��D}��q�=~'�$%�=<ƽ�CC=�A�<���=�HA=�ܔ�~"=EfҼC�Q�)Q��5�<m�<Xl�/�ХX=� ����3�=�l����=�=��\����V�R>whƼ����J���$h=���������н�(*<Ý�9!	>��{м�|8>��<����\v,=����G�)֟�	��=��=[@>��=�K=���	=}v��&�ʧ���ħ�8n������M��75=�黅V�eM<�����|�6����<j�B��)y;�y�=�Xн�<�X[<�.>҂�=�ʞ���=ٸ�V��<ϰ3=s'>$�P�L =�;�>�R6=�*�<�u	>d4n���1���rm6��1�=2#�=�h�=G�?�g1���&���=�����1��ѩ=��������^>�Aǽ6~L�����9�� q�=�fb=���=��Ƚ��i=7K>�\>��=�a>�rp<��	=9�Y=��eq|��ջ��v��c!���>Ū3>�`������� �1���.�)>��r�ޘ%��:=Zy�<�GP����=����/���J�t�;��#�B�S��6�=ZR>	,����<I�d�I��=n5�Z�B=7�
=�S�/�=w�ֽ��!10��u�Mߨ������7�#wj��p�=�_�z$�=8�;�D�=lR=���<�N>�9�=��F>@D�<�0ǹ�ޣ�L =Y껱�^�$=��Q��!d>���:P�2>����	�G�;��m�4%�l}��q�>��H��J<�h-�+Q3=��
=��g蒽1������)a�����;����/��	�>�7��0[%>h�=w��WF�<��w8�l����*=ZL/����=�1k�[^����M���8�A}[=3��=ݒ�����!ğ�9Z=e&�=o�	==�����?>eH�=O=3=�ls��}���J=Y�C������R�S̒�)L�>cz>��=JJ���O=o?6�@2��0�8o�!�ޣ���=�K輶��=�vK>x�o=W3 ��E>��b��~9��>��5���3=��vnN=��
>NQW�R�	>��ѽ�h!��ݼu鳼�!�=D2>��
�Z�ɽIѥ�:?>jQ=�����.>d�h>\F��`Wֽm�v�0d1���D��a��2�=���=�j>8#Y=���>����W=�t�=F������=�d=+C�=KC-��6�>��O���>��=.�7���g��'��?��OK=@{�=ޕ���4%������к>:e�=\|�k����֔:�=vi<��=��
���${1=�o����ỿ��$bA=}�f���O=�џ<t&%=�v�;[T#=��q<è�\�4F��o7�ų�=�'�ÿ���=��=�(~��^���[����<�ǽ'�������=ewu�>�=;��=�Ƚ	�y�ؽ!�>X*̼Ē�=01ļ�� >=��o=OWH�H6��8No=��d=#�d==��=0�B=0߻� ^d=�)���x����O>Z�>O1�=���=���I�[�F���������<妡=>Ǐ�`���=�c]=�^�񴼑
I����~��=���=[�h��<5�;J��=·5���>��a�5����@s�QȬ;�a?=۫0>O�<|c=�{��[IN��Q>$}	>`�)�-k�=,���>�H3��\2�Kό�Bd<r/>� <լS�b��=e}=(�>0�<��Ә">s��<q�w���=	��� �[�vFM��&I<h甽�Q����y�=�FýW�>��v��*��S_<��c�x"����>�@L=�N�=��8= ��=�2�譀=�Jݽ�"+=[� >��=�#>k�^=�5� �O5�P�Q>hΥ��l=]b�<p�j�>yI����=��R�39&h����5>��a��Ǵ�~
������0=ӵӽΦ��ؼ�$�bvl=��f==e������뽰a�<�^��06�#<d�<E��=���������e<�7g�0�M�v� �ABۼ���=�a#>��/�v=���=!i+>/fB�����]�'>X��������l=����k>v�<!D�=�����=[x>5a�<�oҽ��c�b�R8>^2S�����U<`��𰃾���:4�>�K#=�m@<<�x>��/=�~��e�O������gXE�t�v�f4:y�8���9�8�Fx>�&I>�n?=���=�&�L�R>��.�kx��6�=}�4��mW;�㯼�4�<&��؆ҽ`�v=d�=���<N�A�t�L>T������<�dH<t��'5g>�
�>�����)�AO&��꽄&���	�=G~*�gk�<1, =X�={�[����==�=@��6�P<1�=��=$>��=��=W��;�ʽ��0�TЄ��Ȧ<'$��G�=ةF��>=Z�->�-B=J%>�T�<ҽ��=k�>�HA= ���F�������=�8�;L�<r���a�����'�=#%�J�=�<c���N�u��Ll>���s����>��a=ǋ�m�)>�w���%���{��R�;�ay<gĽ��˼�ꑼ*
5�A޷�h�=�,�=�	��]̽[�[<Ve���q�����=p%��uU���6�g�o�������=R�_���?=�$�=>k0=>�i=U��st�=�����<P�^�l����< e�4�Y<��r�����C�<e>�%=3�r��M��t=S,=��½��m�j����Ͱ�5]���M��+�/��c>ޚ\�0��=�<<��ؼ|׿=U.>�h�G���p>qC��� ��������I��=�k�=
%�:�6>���=���X����W>��=�c�<}>��m��'���0<����b�>�˂=���f��6r;�N��h�����=�_�=�:��!sd<5�=��>Qe�=^u#��p�)�R���ܽ�\���p��<J��=����|��=t/�����������%�<�F�=5B>��>��D���2�&ܙ=��>�ݩ=ks¼�<�@�
$�S�!;�-r=��=<�ӹ�U#�׽�~\<P��=�e����p=c��=v�!>];&<n~���H=�V��;��2�ؽ�^>v�p��JQ�V����a���4>�>/>G�q�8m�=�a9=+�K��Lj>U�=���=B������<��=��X����>�=O�s0�(V>>�Wq���9>[w>�M=h01�sx�G��==�ۼ/�S��>�����1�3#ܽ���#�=���><�=�1�&3�=Z켉�a�U۽���=��><^�=C*�=��'>��{=o���)���%�=���Տ��K�>kd>竽�I��a�k>#H\�R�Ƚv-�p�(�b@�l��=��=��=K��>e��;���G���$�=�xQ����<4�=�a�����U��hI�Jv�C�M�h�4>����,>L���9��.��=S��       M��=�L=}�<\<eZ{=������*�q�<�͟�&���o��W=��,,�9݅=A���༩ 	>&�i=�g_=V=       ̇p=y�7=���=P�2=�$=��Y=�=�'c=w,=�ܲ=3a�=!(��-r<>��<���=��I=��=�ѥ=��=�Ռ=       '$!?7?�[�?$(5?��$?��?�� ?�A?qe�?���?B�
?(��?��8?��"? i�>>$p?�R?��o?@?=�?